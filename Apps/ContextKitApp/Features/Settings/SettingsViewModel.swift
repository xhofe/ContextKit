import ContextKitCore
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings = AppSettings()
    @Published var errorMessage: String?

    var didSaveSettings: (() -> Void)?

    let terminalChoices = AppLauncher.knownTerminalLaunchers
    let editorChoices = AppLauncher.knownEditorLaunchers

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

    func setTerminalVisibility(_ isVisible: Bool, for launcher: AppLauncher) {
        performSettingsMutation {
            var visibleIDs = settings.visibleTerminalLauncherIDs
            visibleIDs.removeAll(where: { $0 == launcher.id })

            if isVisible {
                visibleIDs.append(launcher.id)
            }

            try services.updateVisibleTerminalLauncherIDs(visibleIDs)
        }
    }

    func setEditorVisibility(_ isVisible: Bool, for launcher: AppLauncher) {
        performSettingsMutation {
            var visibleIDs = settings.visibleEditorLauncherIDs
            visibleIDs.removeAll(where: { $0 == launcher.id })

            if isVisible {
                visibleIDs.append(launcher.id)
            }

            try services.updateVisibleEditorLauncherIDs(visibleIDs)
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

    func isTerminalVisible(_ launcher: AppLauncher) -> Bool {
        settings.visibleTerminalLauncherIDs.contains(launcher.id)
    }

    func isEditorVisible(_ launcher: AppLauncher) -> Bool {
        settings.visibleEditorLauncherIDs.contains(launcher.id)
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
