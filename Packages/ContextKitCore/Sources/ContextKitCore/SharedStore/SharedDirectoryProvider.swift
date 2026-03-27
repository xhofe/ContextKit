import Foundation

public final class SharedDirectoryProvider: @unchecked Sendable {
    public let appGroupIdentifier: String
    private let fileManager: FileManager

    public init(
        appGroupIdentifier: String = "group.ci.nn.ContextKit",
        fileManager: FileManager = .default
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.fileManager = fileManager
    }

    public func baseURL() throws -> URL {
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            try createDirectoryIfNeeded(at: groupURL)
            return groupURL
        }

        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let fallback = appSupport.appending(path: "ContextKitShared", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: fallback)
        return fallback
    }

    public func settingsURL() throws -> URL {
        try baseURL().appending(path: "settings.json")
    }

    public func menuDescriptorURL() throws -> URL {
        try baseURL().appending(path: "menu-descriptors.json")
    }

    public func workflowsDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: "Workflows", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    public func pluginsDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: "Plugins", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    public func logsURL() throws -> URL {
        try baseURL().appending(path: "execution-log.json")
    }

    public func requestDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: "Requests", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    public func responseDirectoryURL() throws -> URL {
        let url = try baseURL().appending(path: "Responses", directoryHint: .isDirectory)
        try createDirectoryIfNeeded(at: url)
        return url
    }

    private func createDirectoryIfNeeded(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
