import Foundation

public struct ExecutionLogEntry: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var request: ExecutionRequest
    public var result: ExecutionResult
    public var completedAt: Date

    public init(
        id: UUID = UUID(),
        request: ExecutionRequest,
        result: ExecutionResult,
        completedAt: Date = .now
    ) {
        self.id = id
        self.request = request
        self.result = result
        self.completedAt = completedAt
    }
}
