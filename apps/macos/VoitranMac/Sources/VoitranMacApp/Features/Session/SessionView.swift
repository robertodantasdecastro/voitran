import SwiftUI

struct SessionView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Idioma de origem", text: $model.sourceLocale)
            TextField("Idioma de destino", text: $model.targetLocale)
            Text("Status: \(model.sessionStatus)")
            HStack {
                Button("Mock start") {
                    model.sessionStatus = "running"
                }
                Button("Mock stop") {
                    model.sessionStatus = "idle"
                }
            }
            Spacer()
        }
        .textFieldStyle(.roundedBorder)
        .padding(24)
    }
}
