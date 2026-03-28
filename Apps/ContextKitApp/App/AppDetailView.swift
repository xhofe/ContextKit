import SwiftUI

struct AppDetailView: View {
    let container: ContextKitAppContainer
    let selection: AppScreen?

    var body: some View {
        if container.settingsViewModel.settings.monitoredRoots.isEmpty, selection != .settings {
            OnboardingView(viewModel: container.settingsViewModel)
        } else {
            switch selection ?? .overview {
            case .overview:
                OverviewView(viewModel: container.overviewViewModel)
            case .actions:
                ActionsView(viewModel: container.actionsViewModel)
            case .plugins:
                PluginsView(viewModel: container.pluginsViewModel)
            case .workflows:
                WorkflowsView(viewModel: container.workflowsViewModel)
            case .settings:
                SettingsView(viewModel: container.settingsViewModel)
            }
        }
    }
}
