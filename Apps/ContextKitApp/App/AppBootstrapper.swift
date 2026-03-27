import Foundation
import ContextKitCore

struct AppBootstrapper {
    private let pluginRepository: PluginRepository

    init(pluginRepository: PluginRepository) {
        self.pluginRepository = pluginRepository
    }

    func installBundledPluginsIfNeeded(from bundle: Bundle) throws {
        guard let officialDirectory = bundle.resourceURL?.appending(path: "Official", directoryHint: .isDirectory),
              FileManager.default.fileExists(atPath: officialDirectory.path) else {
            return
        }

        let installed = try Set(pluginRepository.installedPlugins().map(\.id))
        let pluginDirectories = try FileManager.default.contentsOfDirectory(at: officialDirectory, includingPropertiesForKeys: nil)
            .filter(\.hasDirectoryPath)

        for directory in pluginDirectories {
            let package = try PluginPackage.load(from: directory)
            guard !installed.contains(package.manifest.id) else {
                continue
            }

            _ = try pluginRepository.install(
                from: directory,
                sourceKind: .bundled,
                sourceDescription: "Bundled official plugin"
            )
            try pluginRepository.trust(pluginID: package.manifest.id)
        }
    }
}
