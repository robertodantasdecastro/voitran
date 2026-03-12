import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var model: AppModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            await model?.handleApplicationLaunch()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        model?.handleApplicationTermination()
    }
}
