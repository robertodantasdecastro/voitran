import SwiftUI

struct HomeView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voitran")
                .font(.largeTitle.bold())
            Text("Shell inicial do produto para traducao de voz em tempo real.")
                .foregroundStyle(.secondary)
            Text("Plataforma: macOS / Apple Silicon")
            Text("Modo: Local-first")
            Text("Par inicial: PT-BR <-> EN")
            Divider()
            Text("Sua voz local")
                .font(.title3.bold())
            Text(model.runtimeReady ? "runtime pronto para Voice Lab" : "runtime ainda nao esta pronto")
            Text("Engine preferencial: \(model.runtimeHealth?.preferredEngine ?? "indisponivel")")
            Text("Servicos ativos: \(model.runningManagedServices)")
            if let models = model.runtimeHealth?.modelsFound, !models.isEmpty {
                Text("Modelos detectados: \(models.joined(separator: ", "))")
            } else {
                Text("Modelos detectados: nenhum")
            }
            if let profile = model.currentProfile {
                Text("Perfil vocal ativo: \(profile.id)")
            } else {
                Text("Perfil vocal ativo: nenhum")
            }
            if let latestSampleSummary = model.latestSampleSummary {
                Text("Amostras prontas: \(latestSampleSummary.samples.count) arquivos / \(latestSampleSummary.totalDurationSeconds.formatted(.number.precision(.fractionLength(1))))s")
            }
            if let smoke = model.lastSmokeReport {
                Text("Smoke operacional: \(smoke.status)")
            }
            if !model.servicesMessage.isEmpty {
                Text(model.servicesMessage)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
}
