import Foundation

public struct ContextKitConfigHomeLocator: @unchecked Sendable {
    private let fileManager: FileManager
    private let homeDirectoryURLProvider: @Sendable () -> URL

    public init(
        fileManager: FileManager = .default,
        homeDirectoryURLProvider: @escaping @Sendable () -> URL = { FileManager.default.homeDirectoryForCurrentUser }
    ) {
        self.fileManager = fileManager
        self.homeDirectoryURLProvider = homeDirectoryURLProvider
    }

    public func resolve() throws -> URL {
        let configDirectory = homeDirectoryURLProvider()
            .appending(path: ".config", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: configDirectory, withIntermediateDirectories: true)

        let contextKitDirectory = configDirectory
            .appending(path: "ContextKit", directoryHint: .isDirectory)
        try fileManager.createDirectory(at: contextKitDirectory, withIntermediateDirectories: true)
        return contextKitDirectory
    }
}
