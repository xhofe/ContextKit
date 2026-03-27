import ContextKitCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
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
                Button(L10n.string("app.settings.addRoot", fallback: "Add Root"), action: viewModel.addRoot)
            }

            Section(L10n.string("app.settings.defaults", fallback: "Defaults")) {
                Picker(L10n.string("app.settings.terminal", fallback: "Terminal"), selection: Binding(
                    get: { viewModel.settings.defaultTerminal.id },
                    set: { id in
                        if let launcher = viewModel.terminalChoices.first(where: { $0.id == id }) {
                            viewModel.saveTerminal(launcher)
                        }
                    }
                )) {
                    ForEach(viewModel.terminalChoices) { launcher in
                        Text(launcher.name).tag(launcher.id)
                    }
                }

                Picker(L10n.string("app.settings.editor", fallback: "Editor"), selection: Binding(
                    get: { viewModel.settings.defaultEditor.id },
                    set: { id in
                        if let launcher = viewModel.editorChoices.first(where: { $0.id == id }) {
                            viewModel.saveEditor(launcher)
                        }
                    }
                )) {
                    ForEach(viewModel.editorChoices) { launcher in
                        Text(launcher.name).tag(launcher.id)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .formStyle(.grouped)
        .padding(24)
        .navigationTitle(L10n.string("app.settings.navigation", fallback: "Settings"))
        .onAppear(perform: viewModel.reload)
    }
}
