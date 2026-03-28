import ContextKitCore
import SwiftUI

struct FinderIntegrationSectionView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Section(L10n.string("app.settings.finder", fallback: "Finder Integration")) {
            Text(
                L10n.string(
                    "app.settings.finderHint",
                    fallback: "ContextKit keeps Finder integration in a separate bridge store so normal app usage does not trigger macOS app-data prompts. Open Finder extension settings when you want to sync the latest monitored roots and menu layout for Finder."
                )
            )
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Button(
                L10n.string(
                    "app.settings.finderOpenButton",
                    fallback: "Sync And Open Finder Extension Settings"
                ),
                action: openFinderSettings
            )
        }
    }

    private func openFinderSettings() {
        viewModel.openFinderExtensionsSettings()
    }
}
