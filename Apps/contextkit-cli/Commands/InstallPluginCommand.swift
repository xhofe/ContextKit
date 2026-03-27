import ContextKitCore
import Foundation

struct InstallPluginCommand {
    let environment: CLIEnvironment

    func execute(arguments: ArraySlice<String>) throws -> InstalledPlugin {
        guard let source = arguments.first else {
            throw CLIError.usage("contextkit plugin install <local-path|git-url>")
        }

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: source) {
            return try environment.localPluginInstaller.install(from: URL(fileURLWithPath: source))
        }

        return try environment.gitPluginInstaller.install(from: source)
    }
}
