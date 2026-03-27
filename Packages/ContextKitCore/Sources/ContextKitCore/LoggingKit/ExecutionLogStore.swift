import Foundation

public final class ExecutionLogStore: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider()) {
        self.directoryProvider = directoryProvider
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func append(_ entry: ExecutionLogEntry) throws {
        var entries = try load()
        entries.insert(entry, at: 0)
        let trimmed = Array(entries.prefix(100))
        let data = try encoder.encode(trimmed)
        let url = try directoryProvider.logsURL()
        try data.write(to: url, options: .atomic)
    }

    public func load() throws -> [ExecutionLogEntry] {
        let url = try directoryProvider.logsURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([ExecutionLogEntry].self, from: data)
    }
}
