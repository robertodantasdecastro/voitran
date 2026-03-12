import SwiftUI

struct RootView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        TabView {
            HomeView(model: model)
                .tabItem { Text("Home") }

            SessionView(model: model)
                .tabItem { Text("Session") }

            VoiceLabView(model: model)
                .tabItem { Text("Voice Lab") }

            SettingsView(model: model)
                .tabItem { Text("Settings") }

            DiagnosticsView(model: model)
                .tabItem { Text("Diagnostics") }
        }
        .frame(minWidth: 960, minHeight: 640)
    }
}
