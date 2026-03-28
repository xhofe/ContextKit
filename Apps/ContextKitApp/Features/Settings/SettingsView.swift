import ContextKitCore
import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Form {
            MonitoredRootsSectionView(viewModel: viewModel)
            FinderIntegrationSectionView(viewModel: viewModel)
            LanguageSectionView(viewModel: viewModel)
            SettingsErrorSectionView(errorMessage: viewModel.errorMessage)
        }
        .formStyle(.grouped)
        .padding(24)
        .navigationTitle(L10n.string("app.settings.navigation", fallback: "Settings"))
        .task {
            viewModel.reload()
        }
    }
}
