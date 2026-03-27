import ContextKitCore
import Foundation

struct AgentGitPluginInstaller {
    private let installer = GitPluginInstaller()

    func install(from repositoryURL: String) throws -> InstalledPlugin {
        try installer.install(from: repositoryURL)
    }
}
