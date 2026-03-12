import SwiftUI

struct VoiceLabView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Voice Lab")
                    .font(.title2.bold())
                Text("Trilha central de identidade vocal com consentimento obrigatorio.")
                    .foregroundStyle(.secondary)

                statusCard
                consentCard
                readinessCard
                guidedCaptureCard
                synthesisCard
                diagnosticsCard
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(24)
        }
        .task {
            await model.refreshRuntime()
            await model.loadExistingProfiles()
        }
    }

    private var statusCard: some View {
        GroupBox("Estado atual") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Fase: \(model.voiceLabPhase.rawValue)")
                Text("Consentimento obrigatorio: \(model.voicePolicy.requiresConsent ? "sim" : "nao")")
                Text("Idiomas aprovados: \(model.voicePolicy.approvedLocales.joined(separator: ", "))")
                Text("Runtime: \(model.runtimeReady ? "pronto" : "indisponivel")")
                if let profile = model.currentProfile {
                    Text("Perfil vocal: \(profile.id)")
                    Text("Engine: \(profile.engine)")
                } else {
                    Text("Perfil vocal: nenhum")
                }
                Text(model.synthesisStatusMessage)
                    .foregroundStyle(model.cloneEngineReady ? .green : .orange)
                if let error = model.lastErrorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var consentCard: some View {
        GroupBox("Consentimento e preparo") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Autorizo o uso local da minha voz para clonagem e testes no Voitran", isOn: $model.consentAccepted)
                    .onChange(of: model.consentAccepted) { _ in
                        model.refreshVoiceLabReadiness()
                    }

                Toggle("Microfone configurado e ambiente silencioso", isOn: $model.readyChecklistComplete)
                    .onChange(of: model.readyChecklistComplete) { _ in
                        model.refreshVoiceLabReadiness()
                    }

                HStack {
                    Button("Solicitar microfone") {
                        Task { await model.requestMicrophoneAccess() }
                    }
                    Button("Revalidar runtime") {
                        Task { await model.refreshRuntime() }
                    }
                }

                Text("Microfone liberado: \(model.microphoneGranted ? "sim" : "nao")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var readinessCard: some View {
        GroupBox("Checklist da fase 1") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Perfil hibrido: clonagem instantanea agora, dataset guiado depois.")
                Text("Meta de gravacao util: 10 a 30 segundos.")
                Text("Duracao atual: \(model.totalRecordedSeconds.formatted(.number.precision(.fractionLength(1))))s")
                Text("Runtime preferencial: \(model.runtimeHealth?.preferredEngine ?? "indisponivel")")
                if !model.runtimeWarnings.isEmpty {
                    Text(model.runtimeWarnings.joined(separator: " | "))
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var guidedCaptureCard: some View {
        GroupBox("Captura guiada") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Frase atual")
                    .font(.headline)
                Text(model.currentPhrase.prompt)
                Text(model.currentPhrase.hint)
                    .foregroundStyle(.secondary)
                Text("Locale: \(model.currentPhrase.locale)")
                Text("Progresso: \(model.recordedSamples.count)/\(model.guidedPhrases.count) frases")
                ProgressView(value: model.recordingLevel)
                Text("Tempo atual: \(model.recordingSeconds.formatted(.number.precision(.fractionLength(1))))s")
                if !model.cloneEngineReady {
                    Text("Aviso: o runtime atual ainda nao clona a voz. O teste de reproducao usa fallback do sistema.")
                        .foregroundStyle(.orange)
                }

                HStack {
                    Button("Iniciar gravacao") {
                        model.startRecordingCurrentPhrase()
                    }
                    .disabled(!model.canAdvanceToRecording || model.isBusy)

                    Button("Parar gravacao") {
                        model.stopRecordingCurrentPhrase()
                    }
                    .disabled(model.voiceLabPhase != .recording)

                    Button("Gerar perfil vocal") {
                        Task { await model.buildVoiceProfile() }
                    }
                    .disabled(!model.canBuildProfile || model.isBusy)

                    Button("Novo perfil de voz") {
                        model.startNewVoiceProfile()
                    }
                    .disabled(!model.canStartNewVoiceProfile)

                    Button("Carregar audios gravados") {
                        Task { await model.loadLatestCapturedSamplesIntoSession() }
                    }
                    .disabled(!model.canUseCapturedSamples)

                    Button("Treinar com audios gravados") {
                        Task { await model.trainProfileFromLatestCapturedSamples() }
                    }
                    .disabled(!model.canTrainFromLatestSamples)
                }

                Button("Smoke test operacional") {
                    Task { await model.runOperationalSmokeTest() }
                }
                .disabled(!model.canRunOperationalSmokeTest)

                if let sampleSummary = model.latestSampleSummary {
                    Text("Amostras prontas no runtime: \(sampleSummary.samples.count) / \(sampleSummary.totalDurationSeconds.formatted(.number.precision(.fractionLength(1))))s")
                        .foregroundStyle(sampleSummary.ready ? .green : .secondary)
                }

                ForEach(model.recordedSamples) { sample in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sample.phrase.id + " - " + sample.phrase.locale)
                            .font(.subheadline.bold())
                        Text(sample.url.lastPathComponent)
                        Text("\(model.resolvedDuration(for: sample).formatted(.number.precision(.fractionLength(1))))s")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var synthesisCard: some View {
        GroupBox("Teste de sintese") {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Texto para ouvir na sua voz local", text: $model.synthesisText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button(model.synthesisButtonTitle) {
                        Task { await model.synthesizePreview() }
                    }
                    .disabled(model.currentProfile == nil || model.isBusy)

                    Button("Revogar perfil local") {
                        Task { await model.revokeCurrentProfile() }
                    }
                    .disabled(model.currentProfile == nil || model.isBusy)
                }

                if let synthesis = model.lastSynthesisResult {
                    Text("Audio: \(synthesis.outputAudioPath)")
                    Text("Latencia: \(synthesis.latencyMilliseconds) ms")
                    Text("Engine: \(synthesis.engine)")
                }
                Text(model.synthesisStatusMessage)
                    .foregroundStyle(model.cloneEngineReady ? .green : .orange)
                if let smoke = model.lastSmokeReport {
                    Text("Smoke report: \(smoke.reportPath)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var diagnosticsCard: some View {
        GroupBox("Readiness para proximas fases") {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.voiceReadyForFutureSession ? "perfil vocal pronto para pipeline futura" : "perfil ainda nao pronto para traducao futura")
                Text("Locale de origem: \(model.sourceLocale)")
                Text("Locale de destino: \(model.targetLocale)")
                Text("Path de saida: \(RuntimePaths.outputsDirectory.path)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
