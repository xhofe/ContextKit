import ContextKitCore
import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {
    var settings = AppSettings()
    var errorMessage: String?
    var finderStatusMessage: String?

    var didSaveSettings: (() -> Void)?

    private let services: ContextKitAppServices

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            settings = try services.loadSettings()
            finderStatusMessage = services.helperRegistrationStatus().message
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

    func saveLanguage(_ language: AppLanguage) {
        performSettingsMutation {
            try services.updateLanguage(language)
        }
    }

    func openFinderExtensionsSettings() {
        do {
            try services.openFinderExtensionsSettings()
            finderStatusMessage = services.helperRegistrationStatus().message
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
