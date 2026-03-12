import SwiftUI

struct VoiceLabView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voice Lab")
                .font(.title2.bold())
            Text("Trilha central de identidade vocal com consentimento obrigatorio.")
                .foregroundStyle(.secondary)
            Text("Consentimento obrigatorio: \(model.voicePolicy.requiresConsent ? "sim" : "nao")")
            Text("Idiomas aprovados: \(model.voicePolicy.approvedLocales.joined(separator: ", "))")
            Button("Registrar fluxo mock") {}
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
}
