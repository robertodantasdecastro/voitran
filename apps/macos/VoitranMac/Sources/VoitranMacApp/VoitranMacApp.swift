import SwiftUI
import AppKit

@main
struct VoitranMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .task {
                    appDelegate.model = model
                    await model.handleApplicationLaunch()
                }
        }
    }
}
