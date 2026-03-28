import ContextKitCore
import Foundation

final class RequestProcessor {
    private let inbox = AgentInbox(directoryProvider: .appGroupBridge())
    private let coordinator = AgentRuntimeFactory.makeCoordinator()

    func processPendingRequests() {
        do {
            let requests = try inbox.pendingRequests()
            for envelope in requests {
                do {
                    let result = try coordinator.execute(envelope.request)
                    try inbox.writeResponse(
                        ExecutionResponseEnvelope(
                            requestID: envelope.id,
                            result: result
                        )
                    )
                } catch {
                    try inbox.writeResponse(
                        ExecutionResponseEnvelope(
                            requestID: envelope.id,
                            result: ExecutionResult(
                                status: .failure,
                                message: error.localizedDescription
                            )
                        )
                    )
                }

                try inbox.removeRequest(id: envelope.id)
            }
        } catch {
            NSLog("ContextKitAgent failed to process requests: %@", error.localizedDescription)
        }
    }
}
