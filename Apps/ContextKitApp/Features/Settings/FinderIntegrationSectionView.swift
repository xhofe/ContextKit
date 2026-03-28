import ContextKitCore
import SwiftUI

struct FinderIntegrationSectionView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Section(L10n.string("app.settings.finder", fallback: "Finder Integration")) {
            Text(
                L10n.string(
                    "app.settings.finderHint",
                    fallback: "ContextKit keeps all app state in ~/.config/ContextKit and serves Finder through a background helper, so normal app usage and Finder menus no longer need access to other apps' data."
                )
            )
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if let finderStatusMessage = viewModel.finderStatusMessage {
                Text(finderStatusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

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
