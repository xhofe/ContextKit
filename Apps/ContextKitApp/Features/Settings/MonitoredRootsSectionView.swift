import ContextKitCore
import SwiftUI

struct MonitoredRootsSectionView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        Section(L10n.string("app.settings.monitoredRoots", fallback: "Monitored Roots")) {
            ForEach(viewModel.settings.monitoredRoots) { root in
                HStack {
                    VStack(alignment: .leading) {
                        Text(root.displayName)
                        Text(root.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(L10n.string("app.settings.remove", fallback: "Remove"), role: .destructive) {
                        viewModel.removeRoot(root)
                    }
                }
            }

            Button(L10n.string("app.settings.addRoot", fallback: "Add Root"), action: addRoot)
        }
    }

    private func addRoot() {
        viewModel.addRoot()
    }
}
