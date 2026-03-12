import Foundation
import SwiftUI
import RealtimeCore

@MainActor
final class AppModel: ObservableObject {
    @Published var sessionStatus = "idle"
    @Published var targetLocale = "en"
    @Published var sourceLocale = "pt-BR"
    @Published var voicePolicy = VoiceIdentityPolicy(
        requiresConsent: true,
        approvedLocales: ["pt-BR", "en"],
        expiresAt: nil,
        retentionPolicy: "local-user-managed"
    )
    @Published var voiceLabPhase: VoiceLabPhase = .consentRequired
    @Published var consentAccepted = false
    @Published var microphoneGranted = false
    @Published var readyChecklistComplete = false
    @Published var runtimeHealth: VoiceRuntimeHealth?
    @Published var runtimeWarnings: [String] = []
    @Published var lastErrorMessage: String?
    @Published var managedServices: [ManagedServiceStatus] = []
    @Published var servicesMessage = ""
    @Published var guidedPhrases: [GuidedPhrase] = [
        GuidedPhrase(
            id: "ptbr-01",
            locale: "pt-BR",
            prompt: "Bom dia. Minha voz local deve soar clara, natural e confiante.",
            hint: "Fale em ritmo normal e em um ambiente silencioso."
        ),
        GuidedPhrase(
            id: "ptbr-02",
            locale: "pt-BR",
            prompt: "Eu autorizo o uso local desta identidade vocal para testes no Voitran.",
            hint: "Evite aproximar demais o microfone para reduzir clipping."
        ),
        GuidedPhrase(
            id: "ptbr-03",
            locale: "pt-BR",
            prompt: "A traducao de voz em tempo real precisa preservar meu timbre e meu sotaque.",
            hint: "Mantenha o mesmo volume da frase anterior."
        ),
        GuidedPhrase(
            id: "en-01",
            locale: "en",
            prompt: "This short sample helps us prepare the voice for future cross-lingual synthesis.",
            hint: "Fale naturalmente, sem tentar imitar outra voz."
        )
    ]
    @Published var currentPhraseIndex = 0
    @Published var recordedSamples: [RecordedVoiceSample] = []
    @Published var recordingSeconds = 0.0
    @Published var recordingLevel = 0.0
    @Published var currentProfile: VoiceProfile?
    @Published var enrollmentResult: VoiceEnrollmentResult?
    @Published var synthesisText = "Ola. Esta e uma amostra local da minha voz sintetizada no Voitran."
    @Published var lastSynthesisResult: VoiceSynthesisResult?
    @Published var isBusy = false
    @Published var debugModeEnabled = true
    @Published var debugLogTail = "nenhum log disponivel"
    @Published var latestSampleSummary: VoiceLabSampleSummary?
    @Published var lastSmokeReport: VoiceLabSmokeReport?

    let capabilityProfile = CapabilityProfile(
        deviceClass: "mac-apple-silicon",
        supportedLocales: ["pt-BR", "en"],
        canRunFullLocalVoice: true
    )

    private let voiceRuntimeService = VoiceRuntimeService()
    private let servicesRuntimeService = ServicesRuntimeService()
    private let audioCaptureService = AudioCaptureService()
    private let audioPlaybackService = AudioPlaybackService()
    private let voiceLabAutomationService = VoiceLabAutomationService()
    private let logger = AppDebugLogger.shared
    private var recordingTimer: Timer?
    private var currentRecordingURL: URL?
    private var didLaunchLifecycle = false
    private let isoFormatter = ISO8601DateFormatter()
    private let ownerLocalID = Host.current().localizedName ?? "mac-local"

    var currentPhrase: GuidedPhrase {
        guidedPhrases[min(currentPhraseIndex, guidedPhrases.count - 1)]
    }

    var totalRecordedSeconds: Double {
        recordedSamples.reduce(0) { $0 + resolvedDuration(for: $1) }
    }

    var runtimeReady: Bool {
        runtimeHealth?.ready == true
    }

    var canAdvanceToRecording: Bool {
        consentAccepted && microphoneGranted && readyChecklistComplete
    }

    var canBuildProfile: Bool {
        totalRecordedSeconds >= 10 && recordedSamples.count >= 3
    }

    var voiceReadyForFutureSession: Bool {
        currentProfile?.status == "ready"
    }

    var runningManagedServices: Int {
        managedServices.filter { ["running", "ready"].contains($0.status) }.count
    }

    var canStartNewVoiceProfile: Bool {
        !isBusy && voiceLabPhase != .recording
    }

    var canUseCapturedSamples: Bool {
        !isBusy && voiceLabPhase != .recording
    }

    var canTrainFromLatestSamples: Bool {
        canUseCapturedSamples && latestSampleSummary?.ready == true
    }

    var canRunOperationalSmokeTest: Bool {
        canTrainFromLatestSamples
    }

    func handleApplicationLaunch() async {
        guard !didLaunchLifecycle else { return }
        didLaunchLifecycle = true
        logger.log("app launch", category: "lifecycle")
        await startManagedDependencies()
        await refreshRuntime()
        await loadExistingProfiles()
        await refreshLatestSamples()
        refreshDebugLogTail()
    }

    func handleApplicationTermination() {
        logger.log("app termination", category: "lifecycle")
        servicesRuntimeService.stopAllSync()
    }

    func refreshManagedServices() async {
        do {
            let response = try await servicesRuntimeService.statusAll()
            managedServices = response.services
            servicesMessage = "status atualizado"
            debug("status de servicos atualizado", category: "services", metadata: ["count": "\(response.services.count)"])
        } catch {
            setError(error)
        }
    }

    func startManagedDependencies() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let response = try await servicesRuntimeService.startAll()
            managedServices = response.services
            servicesMessage = "dependencias iniciadas no launch do app"
            debug("dependencias iniciadas", category: "services")
            if let runtime = response.services.first(where: { $0.id == "voice-runtime" })?.runtimeHealth {
                runtimeHealth = runtime
                runtimeWarnings = runtime.warnings
            }
        } catch {
            setError(error)
        }
    }

    func stopManagedDependencies() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let response = try await servicesRuntimeService.stopAll()
            managedServices = response.services
            servicesMessage = "dependencias encerradas"
            debug("dependencias encerradas", category: "services")
        } catch {
            setError(error)
        }
    }

    func startService(id: String) async {
        isBusy = true
        defer { isBusy = false }

        do {
            let response = try await servicesRuntimeService.start(serviceID: id)
            managedServices = response.services
            servicesMessage = "servico \(id) iniciado"
            debug("servico iniciado", category: "services", metadata: ["service_id": id])
        } catch {
            setError(error)
        }
    }

    func stopService(id: String) async {
        isBusy = true
        defer { isBusy = false }

        do {
            let response = try await servicesRuntimeService.stop(serviceID: id)
            managedServices = response.services
            servicesMessage = "servico \(id) encerrado"
            debug("servico encerrado", category: "services", metadata: ["service_id": id])
        } catch {
            setError(error)
        }
    }

    func refreshRuntime() async {
        do {
            runtimeHealth = try await voiceRuntimeService.health()
            runtimeWarnings = runtimeHealth?.warnings ?? []
            debug(
                "runtime revalidado",
                category: "runtime",
                metadata: [
                    "ready": "\(runtimeHealth?.ready == true)",
                    "preferred_engine": runtimeHealth?.preferredEngine ?? "indisponivel"
                ]
            )
            await refreshManagedServices()
        } catch {
            runtimeHealth = nil
            runtimeWarnings = []
            setError(error)
        }
    }

    func bootstrapRuntime() async {
        isBusy = true
        defer { isBusy = false }

        do {
            _ = try await voiceRuntimeService.bootstrap()
            debug("bootstrap do runtime concluido", category: "runtime")
            await refreshRuntime()
            await refreshManagedServices()
        } catch {
            setError(error)
        }
    }

    func refreshLatestSamples() async {
        do {
            let summary = try await voiceLabAutomationService.latestSamples()
            latestSampleSummary = summary
            debug(
                "amostras mais recentes carregadas",
                category: "voice_lab",
                metadata: [
                    "sample_count": "\(summary.samples.count)",
                    "total_duration_seconds": "\(summary.totalDurationSeconds)",
                    "ready": "\(summary.ready)"
                ]
            )
        } catch {
            setError(error)
        }
    }

    func requestMicrophoneAccess() async {
        microphoneGranted = await audioCaptureService.requestPermission()
        debug("permissao de microfone atualizada", category: "audio", metadata: ["granted": "\(microphoneGranted)"])
        if microphoneGranted && consentAccepted && readyChecklistComplete {
            voiceLabPhase = .readyToRecord
        }
        if !microphoneGranted {
            setError(AudioCaptureError.permissionDenied)
        }
    }

    func refreshVoiceLabReadiness() {
        reconcileVoiceLabState()
    }

    func startRecordingCurrentPhrase() {
        lastErrorMessage = nil
        do {
            let url = RuntimePaths.samplesDirectory.appendingPathComponent("\(currentPhrase.id)-\(UUID().uuidString).wav")
            try audioCaptureService.startRecording(to: url)
            currentRecordingURL = url
            voiceLabPhase = .recording
            debug("gravacao iniciada", category: "audio", metadata: ["phrase_id": currentPhrase.id, "path": url.path])
            recordingSeconds = 0
            recordingLevel = 0
            recordingTimer?.invalidate()
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    self.recordingSeconds += 0.1
                    self.recordingLevel = self.audioCaptureService.currentPowerLevel()
                }
            }
        } catch {
            setError(error)
        }
    }

    func stopRecordingCurrentPhrase() {
        do {
            let duration = try audioCaptureService.stopRecording()
            recordingTimer?.invalidate()
            recordingTimer = nil

            let sampleURL = currentRecordingURL
                ?? RuntimePaths.samplesDirectory.appendingPathComponent("\(currentPhrase.id)-unknown.wav")
            currentRecordingURL = nil

            let sample = RecordedVoiceSample(
                id: UUID().uuidString,
                phrase: currentPhrase,
                url: sampleURL,
                durationSeconds: max(duration, resolvedDuration(at: sampleURL)),
                createdAt: Date()
            )

            recordedSamples.removeAll { $0.phrase.id == currentPhrase.id }
            recordedSamples.append(sample)
            recordedSamples.sort { $0.createdAt < $1.createdAt }
            recordingSeconds = duration
            recordingLevel = 0
            currentPhraseIndex = min(currentPhraseIndex + 1, guidedPhrases.count - 1)
            debug(
                "gravacao finalizada",
                category: "audio",
                metadata: [
                    "phrase_id": sample.phrase.id,
                    "duration_seconds": "\(resolvedDuration(for: sample))",
                    "total_recorded_seconds": "\(totalRecordedSeconds)"
                ]
            )
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func buildVoiceProfile() async {
        guard consentAccepted else {
            setErrorMessage("consentimento obrigatorio antes da criacao do perfil vocal")
            return
        }

        guard canBuildProfile else {
            setErrorMessage("grave ao menos 10 segundos uteis distribuidos em 3 frases")
            return
        }

        isBusy = true
        voiceLabPhase = .profileBuilding
        defer { isBusy = false }

        do {
            let consent = try createConsentManifest()
            let request = VoiceEnrollmentRequest(
                ownerLocalID: ownerLocalID,
                locale: sourceLocale,
                approvedLocales: voicePolicy.approvedLocales,
                samplePaths: recordedSamples.map { $0.url.path },
                consentManifestPath: consent.path
            )
            let result = try await voiceRuntimeService.enroll(request: request)
            enrollmentResult = result
            currentProfile = result.voiceProfile
            runtimeWarnings = result.warnings
            sessionStatus = "voice-profile-ready"
            consentAccepted = true
            readyChecklistComplete = true
            debug("perfil vocal criado", category: "voice_lab", metadata: ["profile_id": result.voiceProfile.id, "latency_ms": "\(result.latencyMilliseconds)"])
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func synthesizePreview() async {
        guard let currentProfile else {
            setErrorMessage("nenhum perfil vocal ativo para sintetizar")
            return
        }

        isBusy = true
        voiceLabPhase = .synthesizing
        defer { isBusy = false }

        do {
            let request = VoiceSynthesisRequest(
                text: synthesisText,
                voiceProfileID: currentProfile.id,
                locale: targetLocale
            )
            let result = try await voiceRuntimeService.synthesize(request: request)
            lastSynthesisResult = result
            runtimeWarnings = result.warnings
            try audioPlaybackService.play(url: URL(fileURLWithPath: result.outputAudioPath))
            debug("sintese concluida", category: "voice_lab", metadata: ["profile_id": result.voiceProfileID, "engine": result.engine, "latency_ms": "\(result.latencyMilliseconds)"])
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func loadExistingProfiles() async {
        do {
            if let profile = try await voiceRuntimeService.listProfiles().last {
                currentProfile = profile
                sessionStatus = profile.status == "ready" ? "voice-profile-ready" : "idle"
                consentAccepted = true
                readyChecklistComplete = true
                debug("perfil existente carregado", category: "voice_lab", metadata: ["profile_id": profile.id, "status": profile.status])
            }
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func loadLatestCapturedSamplesIntoSession() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let summary = try await voiceLabAutomationService.latestSamples()
            latestSampleSummary = summary
            applySampleSummary(summary)
            debug("amostras carregadas na sessao do app", category: "voice_lab", metadata: ["sample_count": "\(summary.samples.count)"])
        } catch {
            setError(error)
        }
    }

    func trainProfileFromLatestCapturedSamples() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let report = try await voiceLabAutomationService.trainLatest(
                ownerLocalID: ownerLocalID,
                sourceLocale: sourceLocale,
                targetLocale: targetLocale
            )
            latestSampleSummary = report.sampleSummary
            applySampleSummary(report.sampleSummary)
            currentProfile = report.enrollment.voiceProfile
            enrollmentResult = report.enrollment
            runtimeWarnings = report.enrollment.warnings
            consentAccepted = true
            readyChecklistComplete = true
            sessionStatus = "voice-profile-ready"
            debug("treino concluido com amostras gravadas", category: "voice_lab", metadata: ["profile_id": report.enrollment.voiceProfile.id])
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func runOperationalSmokeTest() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let report = try await voiceLabAutomationService.smoke(
                ownerLocalID: ownerLocalID,
                sourceLocale: sourceLocale,
                targetLocale: targetLocale,
                text: synthesisText
            )
            latestSampleSummary = report.sampleSummary
            applySampleSummary(report.sampleSummary)
            currentProfile = report.enrollment.voiceProfile
            enrollmentResult = report.enrollment
            lastSynthesisResult = report.synthesis
            lastSmokeReport = report
            runtimeHealth = report.health
            runtimeWarnings = report.health.warnings + report.synthesis.warnings
            consentAccepted = true
            readyChecklistComplete = true
            sessionStatus = "voice-profile-ready"
            debug("smoke test operacional concluido", category: "voice_lab", metadata: ["report_path": report.reportPath, "profile_id": report.enrollment.voiceProfile.id])
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func revokeCurrentProfile() async {
        guard let currentProfile else { return }

        isBusy = true
        defer { isBusy = false }

        do {
            _ = try await voiceRuntimeService.revokeProfile(id: currentProfile.id)
            self.currentProfile = nil
            enrollmentResult = nil
            lastSynthesisResult = nil
            sessionStatus = "idle"
            debug("perfil vocal revogado", category: "voice_lab")
            reconcileVoiceLabState()
        } catch {
            setError(error)
        }
    }

    func startNewVoiceProfile() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        currentRecordingURL = nil
        recordedSamples = []
        recordingSeconds = 0
        recordingLevel = 0
        currentPhraseIndex = 0
        currentProfile = nil
        enrollmentResult = nil
        lastSynthesisResult = nil
        lastSmokeReport = nil
        lastErrorMessage = nil
        sessionStatus = "idle"
        debug("novo perfil vocal iniciado", category: "voice_lab")
        reconcileVoiceLabState()
    }

    func setDebugMode(enabled: Bool) {
        debugModeEnabled = enabled
        logger.log("modo debug atualizado", category: "debug", metadata: ["enabled": "\(enabled)"])
        refreshDebugLogTail()
    }

    func refreshDebugLogTail() {
        debugLogTail = logger.readTail()
    }

    private func createConsentManifest() throws -> URL {
        try FileManager.default.createDirectory(at: RuntimePaths.consentsDirectory, withIntermediateDirectories: true)

        let voiceIdentityID = currentProfile?.id ?? "voice-\(UUID().uuidString)"
        let sampleHash = recordedSamples.map(\.url.path).joined(separator: "|").sha256()
        let expiresAt = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        let manifest = ConsentManifest(
            voiceIdentityID: voiceIdentityID,
            owner: ownerLocalID,
            source: "voitran-macos-guided-enrollment",
            scope: "local-voice-cloning-and-preview",
            expiresAt: isoFormatter.string(from: expiresAt),
            approvedLocales: voicePolicy.approvedLocales,
            hash: sampleHash,
            revocationPolicy: "user-revocable-local-delete"
        )

        let output = RuntimePaths.consentsDirectory.appendingPathComponent("\(voiceIdentityID).json")
        let data = try JSONEncoder().encode(manifest)
        try data.write(to: output, options: .atomic)
        return output
    }

    private func setError(_ error: Error) {
        setErrorMessage(error.localizedDescription)
    }

    private func setErrorMessage(_ message: String) {
        lastErrorMessage = message
        voiceLabPhase = .error
        logger.log("erro", category: "error", metadata: ["message": message])
        refreshDebugLogTail()
    }

    func resolvedDuration(for sample: RecordedVoiceSample) -> Double {
        max(sample.durationSeconds, resolvedDuration(at: sample.url))
    }

    private func resolvedDuration(at url: URL) -> Double {
        AudioCaptureService.recordedDuration(at: url)
    }

    private func applySampleSummary(_ summary: VoiceLabSampleSummary) {
        let samples = summary.samples.compactMap { item -> RecordedVoiceSample? in
            guard let phrase = guidedPhrases.first(where: { $0.id == item.phraseID }) else {
                return nil
            }

            let modifiedDate = ISO8601DateFormatter().date(from: item.modifiedAt) ?? Date()
            return RecordedVoiceSample(
                id: item.path,
                phrase: phrase,
                url: URL(fileURLWithPath: item.path),
                durationSeconds: item.durationSeconds,
                createdAt: modifiedDate
            )
        }

        recordedSamples = samples.sorted { $0.createdAt < $1.createdAt }
        currentPhraseIndex = min(recordedSamples.count, max(guidedPhrases.count - 1, 0))
        reconcileVoiceLabState()
    }

    private func reconcileVoiceLabState() {
        if currentProfile?.status == "ready" {
            voiceLabPhase = .readyForSynthesis
            lastErrorMessage = nil
        } else if canBuildProfile {
            voiceLabPhase = .validating
            lastErrorMessage = nil
        } else if canAdvanceToRecording {
            voiceLabPhase = .readyToRecord
            lastErrorMessage = nil
        } else {
            voiceLabPhase = .consentRequired
        }

        debug(
            "estado do voice lab reconciliado",
            category: "voice_lab",
            metadata: [
                "phase": voiceLabPhase.rawValue,
                "profile_ready": "\(currentProfile?.status == "ready")",
                "recorded_count": "\(recordedSamples.count)",
                "total_recorded_seconds": "\(totalRecordedSeconds)"
            ]
        )
    }

    private func debug(_ message: String, category: String, metadata: [String: String] = [:]) {
        guard debugModeEnabled else { return }
        logger.log(message, category: category, metadata: metadata)
        refreshDebugLogTail()
    }
}

private extension String {
    func sha256() -> String {
        Data(utf8).map { String(format: "%02x", $0) }.joined()
    }
}
