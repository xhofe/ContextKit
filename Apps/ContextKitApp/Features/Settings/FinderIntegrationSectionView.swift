import ContextKitCore
import SwiftUI

struct FinderIntegrationSectionView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Section(L10n.string("app.settings.finder", fallback: "Finder Integration")) {
            Text(
                L10n.string(
                    "app.settings.finderHint",
                    fallback: "Enable the ContextKit Finder extension in System Settings, then use Finder inside one of the monitored roots above. The menu will not appear outside monitored roots."
                )
            )
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Button(
                L10n.string(
                    "app.settings.finderOpenButton",
                    fallback: "Open Finder Extension Settings"
                ),
                action: openFinderSettings
            )
        }
    }

    private func openFinderSettings() {
        viewModel.openFinderExtensionsSettings()
    }
}
