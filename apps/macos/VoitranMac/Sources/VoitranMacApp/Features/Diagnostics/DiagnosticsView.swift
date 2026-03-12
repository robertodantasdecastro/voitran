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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
}
