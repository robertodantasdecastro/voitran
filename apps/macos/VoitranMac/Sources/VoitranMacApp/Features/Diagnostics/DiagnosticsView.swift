import SwiftUI

struct DiagnosticsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diagnostics")
                .font(.title2.bold())
            Text("Classe do dispositivo: \(model.capabilityProfile.deviceClass)")
            Text("Idiomas: \(model.capabilityProfile.supportedLocales.joined(separator: ", "))")
            Text("Voz local completa: \(model.capabilityProfile.canRunFullLocalVoice ? "sim" : "nao")")
            Text("Runtime pronto: \(model.runtimeReady ? "sim" : "nao")")
            Text("Servicos gerenciados: \(model.managedServices.count)")
            Text("Fase do Voice Lab: \(model.voiceLabPhase.rawValue)")
            Text("Duracao util capturada: \(model.totalRecordedSeconds.formatted(.number.precision(.fractionLength(1))))s")
            if let result = model.enrollmentResult {
                Text("Latencia do build do perfil: \(result.latencyMilliseconds) ms")
            }
            if let synthesis = model.lastSynthesisResult {
                Text("Ultima sintese: \(synthesis.latencyMilliseconds) ms via \(synthesis.engine)")
            }
            if !model.runtimeWarnings.isEmpty {
                Text("Warnings: \(model.runtimeWarnings.joined(separator: " | "))")
                    .foregroundStyle(.orange)
            }
            if let error = model.lastErrorMessage {
                Text("Erro atual: \(error)")
                    .foregroundStyle(.red)
            }
            ForEach(model.managedServices) { service in
                Text("\(service.name): \(service.status)")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
}
