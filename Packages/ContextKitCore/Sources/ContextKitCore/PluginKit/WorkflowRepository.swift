import Foundation

public final class WorkflowRepository: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let encoder = JSONEncoder()
    private let loader = WorkflowManifestLoader()

    public init(directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider()) {
        self.directoryProvider = directoryProvider
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func list() throws -> [WorkflowManifest] {
        let directory = try directoryProvider.workflowsDirectoryURL()
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        return try files
            .filter { $0.pathExtension == "json" }
            .map { try loader.load(from: $0) }
            .sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
    }

    public func load(id: String) throws -> WorkflowManifest {
        let url = try workflowURL(for: id)
        return try loader.load(from: url)
    }

    public func save(_ manifest: WorkflowManifest) throws {
        let url = try workflowURL(for: manifest.id)
        let data = try encoder.encode(manifest)
        try data.write(to: url, options: .atomic)
    }

    public func remove(id: String) throws {
        let url = try workflowURL(for: id)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try FileManager.default.removeItem(at: url)
    }

    private func workflowURL(for id: String) throws -> URL {
        let directory = try directoryProvider.workflowsDirectoryURL()
        return directory.appending(path: "\(id).json")
    }
}
