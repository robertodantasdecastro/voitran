import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voitran")
                .font(.largeTitle.bold())
            Text("Shell inicial do produto para traducao de voz em tempo real.")
                .foregroundStyle(.secondary)
            Text("Plataforma: macOS / Apple Silicon")
            Text("Modo: Local-first")
            Text("Par inicial: PT-BR <-> EN")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
    }
}
