import ContextKitCore
import Foundation

struct AgentLocalPluginInstaller {
    private let installer = LocalPluginInstaller()

    func install(from directory: URL) throws -> InstalledPlugin {
        try installer.install(from: directory)
    }
}
