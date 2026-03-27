import Foundation

public struct ExecutionLogLine: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var timestamp: Date
    public var level: String
    public var message: String

    public init(id: UUID = UUID(), timestamp: Date = .now, level: String = "info", message: String) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
    }
}
