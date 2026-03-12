import SwiftUI

struct RootView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Text("Home") }

            SessionView(model: model)
                .tabItem { Text("Session") }

            VoiceLabView(model: model)
                .tabItem { Text("Voice Lab") }

            SettingsView()
                .tabItem { Text("Settings") }

            DiagnosticsView(model: model)
                .tabItem { Text("Diagnostics") }
        }
        .frame(minWidth: 960, minHeight: 640)
    }
}
