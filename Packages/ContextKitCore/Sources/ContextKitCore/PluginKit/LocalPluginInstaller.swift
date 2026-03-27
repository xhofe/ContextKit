import Foundation

public struct LocalPluginInstaller: Sendable {
    private let pluginRepository: PluginRepository

    public init(pluginRepository: PluginRepository = PluginRepository()) {
        self.pluginRepository = pluginRepository
    }

    public func install(from sourceDirectory: URL, sourceDescription: String? = nil) throws -> InstalledPlugin {
        try pluginRepository.install(
            from: sourceDirectory,
            sourceKind: .local,
            sourceDescription: sourceDescription ?? sourceDirectory.path
        )
    }
}
