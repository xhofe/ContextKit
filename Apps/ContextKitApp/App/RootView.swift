import ContextKitCore
import SwiftUI

struct RootView: View {
    @ObservedObject var container: ContextKitAppContainer
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @State private var selection: AppScreen? = .overview

    init(container: ContextKitAppContainer) {
        _container = ObservedObject(wrappedValue: container)
        _settingsViewModel = ObservedObject(wrappedValue: container.settingsViewModel)
    }

    var body: some View {
        NavigationSplitView {
            List(AppScreen.allCases, selection: $selection) { screen in
                Label(screen.title, systemImage: screen.systemImage)
                    .tag(screen)
            }
            .navigationTitle("ContextKit")
            .listStyle(.sidebar)
        } detail: {
            if settingsViewModel.settings.monitoredRoots.isEmpty, selection != .settings {
                OnboardingView(viewModel: settingsViewModel)
            } else {
                detailContent
            }
        }
        .frame(minWidth: 960, minHeight: 640)
        .environment(\.locale, settingsViewModel.settings.language.locale)
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
            SettingsView(viewModel: settingsViewModel)
        }
    }
}
