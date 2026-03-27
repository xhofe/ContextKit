import ContextKitCore
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings = AppSettings()
    @Published var errorMessage: String?

    let terminalChoices: [AppLauncher] = [
        .terminalDefault,
        AppLauncher(id: "terminal.iterm", name: "iTerm", bundleIdentifier: "com.googlecode.iterm2"),
        AppLauncher(id: "terminal.warp", name: "Warp", bundleIdentifier: "dev.warp.Warp-Stable"),
        AppLauncher(id: "terminal.ghostty", name: "Ghostty", bundleIdentifier: "com.mitchellh.ghostty"),
    ]

    let editorChoices: [AppLauncher] = [
        .editorDefault,
        AppLauncher(id: "editor.cursor", name: "Cursor", bundleIdentifier: "com.todesktop.230313mzl4w4u92"),
    ]

    private let services: ContextKitAppServices

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            settings = try services.loadSettings()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addRoot() {
        do {
            guard let url = services.chooseDirectory() else { return }
            try services.addMonitoredRoot(url: url)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeRoot(_ root: MonitoredRoot) {
        do {
            try services.removeMonitoredRoot(root)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveTerminal(_ launcher: AppLauncher) {
        do {
            try services.updateDefaultTerminal(launcher)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveEditor(_ launcher: AppLauncher) {
        do {
            try services.updateDefaultEditor(launcher)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
