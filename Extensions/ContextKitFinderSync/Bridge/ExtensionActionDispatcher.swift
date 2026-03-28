import ContextKitCore
import Foundation

struct ExtensionActionDispatcher {
    private let helperClient = ContextKitHelperClient(timeout: 30.0)

    func dispatch(_ request: FinderExecutionRequest) throws -> FinderExecutionResult {
        try helperClient.execute(request)
    }
}
