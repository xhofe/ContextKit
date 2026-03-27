import AppKit
import ContextKitCore
import Foundation

final class MenuActionHandler: NSObject, @unchecked Sendable {
    static let shared = MenuActionHandler()

    private let dispatcher = ExtensionActionDispatcher()

    @objc func handleMenuItem(_ sender: NSMenuItem) {
        guard let payload = sender.representedObject as? MenuInvocationPayload else {
            NSLog("ContextKitFinderSync menu click missing payload for item: %@", sender.title)
            return
        }

        do {
            try dispatcher.dispatch(payload.request)
            NSLog("ContextKitFinderSync dispatched request: %@", payload.request.targetId)
        } catch {
            NSLog(
                "ContextKitFinderSync failed to dispatch request %@: %@",
                payload.request.targetId,
                error.localizedDescription
            )
        }
    }
}
