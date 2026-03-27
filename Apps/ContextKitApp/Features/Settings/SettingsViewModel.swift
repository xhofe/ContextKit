import ContextKitCore
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings = AppSettings()
    @Published var errorMessage: String?

    var didSaveSettings: (() -> Void)?

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
        guard let url = services.chooseDirectory() else { return }
        performSettingsMutation {
            try services.addMonitoredRoot(url: url)
        }
    }

    func removeRoot(_ root: MonitoredRoot) {
        performSettingsMutation {
            try services.removeMonitoredRoot(root)
        }
    }

    func saveTerminal(_ launcher: AppLauncher) {
        performSettingsMutation {
            try services.updateDefaultTerminal(launcher)
        }
    }

    func saveEditor(_ launcher: AppLauncher) {
        performSettingsMutation {
            try services.updateDefaultEditor(launcher)
        }
    }

    func saveLanguage(_ language: AppLanguage) {
        performSettingsMutation {
            try services.updateLanguage(language)
        }
    }

    func openFinderExtensionsSettings() {
        do {
            try services.openFinderExtensionsSettings()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSettingsMutation(_ operation: () throws -> Void) {
        do {
            try operation()
            reload()
            didSaveSettings?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
