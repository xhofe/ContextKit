import AppKit
import Foundation

@MainActor
final class ContextKitAppDelegate: NSObject, NSApplicationDelegate {
    private let agentLauncher = EmbeddedAgentLauncher()

    func applicationWillTerminate(_ notification: Notification) {
        agentLauncher.terminateIfRunning()
    }
}
