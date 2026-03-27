import Foundation

public struct GitPluginInstaller: Sendable {
    private let pluginRepository: PluginRepository
    private let processRunner: ProcessRunner

    public init(
        pluginRepository: PluginRepository = PluginRepository(),
        processRunner: ProcessRunner = ProcessRunner()
    ) {
        self.pluginRepository = pluginRepository
        self.processRunner = processRunner
    }

    public func install(from repositoryURL: String) throws -> InstalledPlugin {
        let tempDirectory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let cloneOutput = try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/git"),
            arguments: ["clone", "--depth", "1", repositoryURL, tempDirectory.path]
        )
        guard cloneOutput.terminationStatus == 0 else {
            throw ExecutionCoordinatorError.processFailed(cloneOutput.standardError)
        }

        let revisionOutput = try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/git"),
            arguments: ["rev-parse", "HEAD"],
            currentDirectoryURL: tempDirectory
        )
        let revision = revisionOutput.standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)

        return try pluginRepository.install(
            from: tempDirectory,
            sourceKind: .git,
            sourceDescription: repositoryURL,
            revision: revision.isEmpty ? nil : revision
        )
    }
}
