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

    let capabilityProfile = CapabilityProfile(
        deviceClass: "mac-apple-silicon",
        supportedLocales: ["pt-BR", "en"],
        canRunFullLocalVoice: true
    )

    private let voiceRuntimeService = VoiceRuntimeService()
    private let servicesRuntimeService = ServicesRuntimeService()
    private let audioCaptureService = AudioCaptureService()
    private let audioPlaybackService = AudioPlaybackService()
    private var recordingTimer: Timer?
    private var currentRecordingURL: URL?
    private var didLaunchLifecycle = false
    private let isoFormatter = ISO8601DateFormatter()
    private let ownerLocalID = Host.current().localizedName ?? "mac-local"

    var currentPhrase: GuidedPhrase {
        guidedPhrases[min(currentPhraseIndex, guidedPhrases.count - 1)]
    }

    var totalRecordedSeconds: Double {
        recordedSamples.reduce(0) { $0 + $1.durationSeconds }
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

    func handleApplicationLaunch() async {
        guard !didLaunchLifecycle else { return }
        didLaunchLifecycle = true
        await startManagedDependencies()
        await refreshRuntime()
        await loadExistingProfiles()
    }

    func handleApplicationTermination() {
        servicesRuntimeService.stopAllSync()
    }

    func refreshManagedServices() async {
        do {
            let response = try await servicesRuntimeService.statusAll()
            managedServices = response.services
            servicesMessage = "status atualizado"
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
        } catch {
            setError(error)
        }
    }

    func refreshRuntime() async {
        do {
            runtimeHealth = try await voiceRuntimeService.health()
            runtimeWarnings = runtimeHealth?.warnings ?? []
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
            await refreshRuntime()
            await refreshManagedServices()
        } catch {
            setError(error)
        }
    }

    func requestMicrophoneAccess() async {
        microphoneGranted = await audioCaptureService.requestPermission()
        if microphoneGranted && consentAccepted && readyChecklistComplete {
            voiceLabPhase = .readyToRecord
        }
        if !microphoneGranted {
            setError(AudioCaptureError.permissionDenied)
        }
    }

    func refreshVoiceLabReadiness() {
        if canAdvanceToRecording {
            voiceLabPhase = .readyToRecord
            lastErrorMessage = nil
        } else if !consentAccepted {
            voiceLabPhase = .consentRequired
        }
    }

    func startRecordingCurrentPhrase() {
        lastErrorMessage = nil
        do {
            let url = RuntimePaths.samplesDirectory.appendingPathComponent("\(currentPhrase.id)-\(UUID().uuidString).wav")
            try audioCaptureService.startRecording(to: url)
            currentRecordingURL = url
            voiceLabPhase = .recording
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
                durationSeconds: duration,
                createdAt: Date()
            )

            recordedSamples.removeAll { $0.phrase.id == currentPhrase.id }
            recordedSamples.append(sample)
            recordedSamples.sort { $0.createdAt < $1.createdAt }
            recordingSeconds = duration
            recordingLevel = 0
            currentPhraseIndex = min(currentPhraseIndex + 1, guidedPhrases.count - 1)
            voiceLabPhase = canBuildProfile ? .validating : .readyToRecord
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
            voiceLabPhase = .readyForSynthesis
            sessionStatus = "voice-profile-ready"
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
            voiceLabPhase = .readyForSynthesis
        } catch {
            setError(error)
        }
    }

    func loadExistingProfiles() async {
        do {
            if let profile = try await voiceRuntimeService.listProfiles().last {
                currentProfile = profile
                sessionStatus = profile.status == "ready" ? "voice-profile-ready" : "idle"
            }
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
            voiceLabPhase = canAdvanceToRecording ? .readyToRecord : .consentRequired
        } catch {
            setError(error)
        }
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
    }
}

private extension String {
    func sha256() -> String {
        Data(utf8).map { String(format: "%02x", $0) }.joined()
    }
}
