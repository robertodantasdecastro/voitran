import SwiftUI

struct SessionView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Idioma de origem", text: $model.sourceLocale)
            TextField("Idioma de destino", text: $model.targetLocale)
            Text("Status: \(model.sessionStatus)")
            Text(model.voiceReadyForFutureSession ? "voz local pronta para etapas futuras de traducao" : "voz local ainda nao esta pronta")
            HStack {
                Button("Mock start") {
                    model.sessionStatus = "running"
                }
                Button("Mock stop") {
                    model.sessionStatus = "idle"
                }
            }
            if let profile = model.currentProfile {
                Text("Perfil ativo: \(profile.id)")
                Text("Engine: \(profile.engine)")
            }
            Spacer()
        }
        .textFieldStyle(.roundedBorder)
        .padding(24)
    }
}
