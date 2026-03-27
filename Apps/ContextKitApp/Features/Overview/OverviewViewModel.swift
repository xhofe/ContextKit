import ContextKitCore
import Foundation

@MainActor
final class OverviewViewModel: ObservableObject {
    @Published var actionCount = 0
    @Published var pluginCount = 0
    @Published var workflowCount = 0
    @Published var monitoredRootCount = 0
    @Published var recentLogs: [ExecutionLogEntry] = []
    @Published var errorMessage: String?

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
