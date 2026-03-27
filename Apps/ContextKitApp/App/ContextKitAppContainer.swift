import Foundation

@MainActor
final class ContextKitAppContainer: ObservableObject {
    let services: ContextKitAppServices
    let overviewViewModel: OverviewViewModel
    let actionsViewModel: ActionsViewModel
    let pluginsViewModel: PluginsViewModel
    let workflowsViewModel: WorkflowsViewModel
    let settingsViewModel: SettingsViewModel

    init() {
        let services = ContextKitAppServices()
        self.services = services
        self.overviewViewModel = OverviewViewModel(services: services)
        self.actionsViewModel = ActionsViewModel(services: services)
        self.pluginsViewModel = PluginsViewModel(services: services)
        self.workflowsViewModel = WorkflowsViewModel(services: services)
        self.settingsViewModel = SettingsViewModel(services: services)
    }

    func reloadAll() {
        overviewViewModel.reload()
        actionsViewModel.reload()
        pluginsViewModel.reload()
        workflowsViewModel.reload()
        settingsViewModel.reload()
    }
}
