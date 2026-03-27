import Foundation

public struct ExecutionResponseEnvelope: Codable, Hashable, Sendable {
    public var requestID: UUID
    public var result: ExecutionResult
    public var completedAt: Date

    public init(requestID: UUID, result: ExecutionResult, completedAt: Date = .now) {
        self.requestID = requestID
        self.result = result
        self.completedAt = completedAt
    }
}
