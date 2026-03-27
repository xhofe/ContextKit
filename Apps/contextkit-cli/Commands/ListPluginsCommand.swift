import ContextKitCore
import Foundation

struct ListPluginsCommand {
    let environment: CLIEnvironment

    func execute() throws -> [InstalledPlugin] {
        try environment.pluginRepository.installedPlugins()
    }
}
