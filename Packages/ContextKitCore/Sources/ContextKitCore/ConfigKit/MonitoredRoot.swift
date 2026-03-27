import Foundation

public struct MonitoredRoot: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var path: String
    public var displayName: String

    public init(id: UUID = UUID(), path: String, displayName: String) {
        self.id = id
        self.path = path
        self.displayName = displayName
    }

    public var url: URL {
        URL(fileURLWithPath: path)
    }
}
