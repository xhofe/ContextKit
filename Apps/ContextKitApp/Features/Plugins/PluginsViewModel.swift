import ContextKitCore
import Foundation

@MainActor
final class PluginsViewModel: ObservableObject {
    @Published var plugins: [InstalledPlugin] = []
    @Published var gitRepositoryURL = ""
    @Published var statusMessage: String?
    @Published var errorMessage: String?

    private let services: ContextKitAppServices

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            plugins = try services.loadPlugins()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func installLocalPlugin() {
        do {
            guard let directory = services.chooseDirectory() else { return }
            let plugin = try services.installLocalPlugin(from: directory)
            statusMessage = L10n.string(
                "app.plugins.status.installedLocal",
                fallback: "Installed %@. Review trust status below.",
                plugin.package.manifest.name
            )
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func installGitPlugin() {
        guard !gitRepositoryURL.isEmpty else { return }
        do {
            let plugin = try services.installGitPlugin(from: gitRepositoryURL)
            statusMessage = L10n.string(
                "app.plugins.status.installedGit",
                fallback: "Installed %@ from Git.",
                plugin.package.manifest.name
            )
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func trust(_ plugin: InstalledPlugin) {
        do {
            try services.trustPlugin(plugin.id)
            statusMessage = L10n.string(
                "app.plugins.status.trusted",
                fallback: "Trusted %@.",
                plugin.package.manifest.name
            )
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ plugin: InstalledPlugin) {
        do {
            try services.removePlugin(plugin.id)
            statusMessage = L10n.string(
                "app.plugins.status.removed",
                fallback: "Removed %@.",
                plugin.package.manifest.name
            )
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
