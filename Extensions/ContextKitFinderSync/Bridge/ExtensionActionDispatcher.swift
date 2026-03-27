import ContextKitCore
import Foundation

struct ExtensionActionDispatcher {
    private let inbox = AgentInbox()

    func dispatch(_ request: ExecutionRequest) {
        do {
            _ = try inbox.enqueue(request)
        } catch {
            NSLog("Failed to dispatch Finder request: %@", error.localizedDescription)
        }
    }
}
