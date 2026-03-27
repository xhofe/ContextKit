import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Monitored Roots") {
                ForEach(viewModel.settings.monitoredRoots) { root in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(root.displayName)
                            Text(root.path)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Remove", role: .destructive) {
                            viewModel.removeRoot(root)
                        }
                    }
                }
                Button("Add Root", action: viewModel.addRoot)
            }

            Section("Defaults") {
                Picker("Terminal", selection: Binding(
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

                Picker("Editor", selection: Binding(
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
        .navigationTitle("Settings")
        .onAppear(perform: viewModel.reload)
    }
}
