import SwiftUI

struct RootView: View {
    @ObservedObject var container: ContextKitAppContainer
    @State private var selection: AppScreen? = .overview

    var body: some View {
        NavigationSplitView {
            List(AppScreen.allCases, selection: $selection) { screen in
                Label(screen.title, systemImage: screen.systemImage)
                    .tag(screen)
            }
            .navigationTitle("ContextKit")
            .listStyle(.sidebar)
        } detail: {
            if container.settingsViewModel.settings.monitoredRoots.isEmpty, selection != .settings {
                OnboardingView(viewModel: container.settingsViewModel)
            } else {
                detailContent
            }
        }
        .frame(minWidth: 960, minHeight: 640)
    }

    @ViewBuilder
    private var detailContent: some View {
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
