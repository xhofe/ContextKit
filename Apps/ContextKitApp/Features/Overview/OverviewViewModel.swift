import ContextKitCore
import Foundation
import Observation

@Observable
@MainActor
final class OverviewViewModel {
    var actionCount = 0
    var pluginCount = 0
    var workflowCount = 0
    var monitoredRootCount = 0
    var recentLogs: [ExecutionLogEntry] = []
    var errorMessage: String?

    private let services: ContextKitAppServices

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            let catalog = try services.loadCatalog()
            let settings = try services.loadSettings()
            actionCount = catalog.actions.count
            pluginCount = try services.loadPlugins().count
            workflowCount = catalog.workflows.count
            monitoredRootCount = settings.monitoredRoots.count
            recentLogs = try services.loadLogs().prefix(6).map { $0 }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
