import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Priorizar pipeline local", isOn: .constant(true))
            Toggle("Permitir degradacao para legenda traduzida", isOn: .constant(true))
            Toggle("Exigir consentimento de voz", isOn: .constant(true))
            Spacer()
        }
        .padding(24)
    }
}
