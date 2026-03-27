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
        let settingsViewModel = SettingsViewModel(services: services)
        self.services = services
        self.overviewViewModel = OverviewViewModel(services: services)
        self.actionsViewModel = ActionsViewModel(services: services)
        self.pluginsViewModel = PluginsViewModel(services: services)
        self.workflowsViewModel = WorkflowsViewModel(services: services)
        self.settingsViewModel = settingsViewModel

        settingsViewModel.didSaveSettings = { [weak self] in
            self?.reloadDerivedData()
        }
    }

    func reloadAll() {
        settingsViewModel.reload()
        reloadDerivedData()
    }

    private func reloadDerivedData() {
        overviewViewModel.reload()
        actionsViewModel.reload()
        pluginsViewModel.reload()
        workflowsViewModel.reload()
    }
}
