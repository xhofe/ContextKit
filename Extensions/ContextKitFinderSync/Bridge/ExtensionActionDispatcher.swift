import ContextKitCore
import AppKit
import Foundation

struct ExtensionActionDispatcher {
    private let inbox = AgentInbox(directoryProvider: .appGroupBridge())
    private let agentLauncher = FinderAgentLauncher()

    func dispatch(_ request: ExecutionRequest) throws {
        agentLauncher.launchIfNeeded()
        _ = try inbox.enqueue(request)
    }
}
