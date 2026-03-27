import Foundation

public struct ExecutionRequestEnvelope: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var request: ExecutionRequest
    public var createdAt: Date

    public init(id: UUID = UUID(), request: ExecutionRequest, createdAt: Date = .now) {
        self.id = id
        self.request = request
        self.createdAt = createdAt
    }
}
