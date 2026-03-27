import Foundation

public final class SharedDirectoryProvider: @unchecked Sendable {
    public let appGroupIdentifier: String?
    public let legacyAppGroupIdentifier: String?
    private let fileManager: FileManager

    public init(
        appGroupIdentifier: String? = SharedDirectoryProvider.defaultAppGroupIdentifier(),
        legacyAppGroupIdentifier: String? = "group.ci.nn.ContextKit",
        fileManager: FileManager = .default
    ) {
        self.appGroupIdentifier = appGroupIdentifier
        self.legacyAppGroupIdentifier = legacyAppGroupIdentifier
        self.fileManager = fileManager
    }

    public func baseURL() throws -> URL {
        if let groupURL = preferredGroupURL() {
            try prepareGroupDirectory(at: groupURL)
            return groupURL
        }

        if let legacyGroupURL = legacyGroupURL() {
            try createDirectoryIfNeeded(at: legacyGroupURL)
            return legacyGroupURL
        }

        let fallback = try fallbackURL()
        try createDirectoryIfNeeded(at: fallback)
        return fallback
    }

    public static func defaultAppGroupIdentifier(bundle: Bundle = .main) -> String? {
        (bundle.object(forInfoDictionaryKey: "ContextKitAppGroupIdentifier") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
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

    private func preferredGroupURL() -> URL? {
        containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    private func legacyGroupURL() -> URL? {
        containerURL(forSecurityApplicationGroupIdentifier: legacyAppGroupIdentifier)
    }

    private func containerURL(forSecurityApplicationGroupIdentifier identifier: String?) -> URL? {
        guard let identifier, !identifier.isEmpty else {
            return nil
        }

        return fileManager.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    private func fallbackURL() throws -> URL {
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return appSupport.appending(path: "ContextKitShared", directoryHint: .isDirectory)
    }

    private func prepareGroupDirectory(at destination: URL) throws {
        if !fileManager.fileExists(atPath: destination.path),
           let source = try firstMigrationSourceURL() {
            try fileManager.copyItem(at: source, to: destination)
            return
        }

        if isEmptyDirectory(at: destination),
           let source = try firstMigrationSourceURL() {
            try fileManager.removeItem(at: destination)
            try fileManager.copyItem(at: source, to: destination)
            return
        }

        try createDirectoryIfNeeded(at: destination)
    }

    private func firstMigrationSourceURL() throws -> URL? {
        let sources = [legacyGroupURL(), try fallbackURL()]
        return sources.compactMap { $0 }.first(where: { fileManager.fileExists(atPath: $0.path) })
    }

    private func isEmptyDirectory(at url: URL) -> Bool {
        guard fileManager.fileExists(atPath: url.path) else {
            return false
        }

        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey]
        guard let values = try? url.resourceValues(forKeys: resourceKeys),
              values.isDirectory == true else {
            return false
        }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return false
        }

        return contents.isEmpty
    }

    private func createDirectoryIfNeeded(at url: URL) throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
