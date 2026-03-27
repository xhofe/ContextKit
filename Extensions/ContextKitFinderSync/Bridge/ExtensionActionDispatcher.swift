import ContextKitCore
import Foundation

struct ExtensionActionDispatcher {
    private let inbox = AgentInbox()

    func dispatch(_ request: ExecutionRequest) throws {
        _ = try inbox.enqueue(request)
    }
}
