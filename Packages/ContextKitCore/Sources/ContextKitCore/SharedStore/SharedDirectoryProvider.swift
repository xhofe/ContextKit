import Foundation

public final class SharedDirectoryProvider: @unchecked Sendable {
    private let configHomeLocator: ContextKitConfigHomeLocator
    private let fileManager: FileManager

    public init(
        configHomeLocator: ContextKitConfigHomeLocator = ContextKitConfigHomeLocator(),
        fileManager: FileManager = .default
    ) {
        self.configHomeLocator = configHomeLocator
        self.fileManager = fileManager
    }

    public func baseURL() throws -> URL {
        try configHomeLocator.resolve()
    }

    public func settingsURL() throws -> URL {
        try baseURL().appending(path: "settings.json")
    }

    public func workflowsDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: "workflows", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    public func pluginsDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: "plugins", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    public func logsURL() throws -> URL {
        let directory = try baseURL().appending(path: "logs", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: directory)
        return directory.appending(path: "execution-log.json")
    }

    public func menuDescriptorURL() throws -> URL {
        let directory = try internalDirectoryURL()
            .appending(path: "cache", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: directory)
        return directory.appending(path: "menu-descriptors.json")
    }

    public func ipcBaseURLs() throws -> [URL] {
        [try internalDirectoryURL().resolvingSymlinksInPath().standardizedFileURL]
    }

    public func requestDirectoryURL() throws -> URL {
        let url = try internalDirectoryURL()
            .appending(path: "ipc/Requests", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    public func responseDirectoryURL() throws -> URL {
        let url = try internalDirectoryURL()
            .appending(path: "ipc/Responses", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    private func internalDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: ".internal", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    private func createDirectoryIfNeeded(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
