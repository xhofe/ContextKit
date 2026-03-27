import AppKit
import Foundation

final class AgentAppDelegate: NSObject, NSApplicationDelegate {
    private let requestListener = ExecutionRequestListener()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        requestListener.start()
    }
}
