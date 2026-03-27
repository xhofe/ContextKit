import ContextKitCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            monitoredRootsSection
            defaultsSection
            localizationSection
            errorSection
        }
        .formStyle(.grouped)
        .padding(24)
        .navigationTitle(L10n.string("app.settings.navigation", fallback: "Settings"))
        .onAppear(perform: viewModel.reload)
    }

    private var monitoredRootsSection: some View {
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
    }

    private var defaultsSection: some View {
        Section(L10n.string("app.settings.defaults", fallback: "Defaults")) {
            Picker(L10n.string("app.settings.terminal", fallback: "Terminal"), selection: terminalSelection) {
                ForEach(viewModel.terminalChoices) { launcher in
                    Text(launcher.name).tag(launcher.id)
                }
            }

            Picker(L10n.string("app.settings.editor", fallback: "Editor"), selection: editorSelection) {
                ForEach(viewModel.editorChoices) { launcher in
                    Text(launcher.name).tag(launcher.id)
                }
            }
        }
    }

    private var localizationSection: some View {
        Section(L10n.string("app.settings.localization", fallback: "Localization")) {
            Picker(L10n.string("app.settings.language", fallback: "Language"), selection: languageSelection) {
                Text(AppLanguage.system.displayName).tag(AppLanguage.system.rawValue)
                Text(AppLanguage.english.displayName).tag(AppLanguage.english.rawValue)
                Text(AppLanguage.simplifiedChinese.displayName).tag(AppLanguage.simplifiedChinese.rawValue)
            }
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage = viewModel.errorMessage {
            Section {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
    }

    private var terminalSelection: Binding<String> {
        Binding(
            get: { viewModel.settings.defaultTerminal.id },
            set: { id in
                if let launcher = viewModel.terminalChoices.first(where: { $0.id == id }) {
                    viewModel.saveTerminal(launcher)
                }
            }
        )
    }

    private var editorSelection: Binding<String> {
        Binding(
            get: { viewModel.settings.defaultEditor.id },
            set: { id in
                if let launcher = viewModel.editorChoices.first(where: { $0.id == id }) {
                    viewModel.saveEditor(launcher)
                }
            }
        )
    }

    private var languageSelection: Binding<String> {
        Binding(
            get: { viewModel.settings.language.rawValue },
            set: { rawValue in
                if let language = AppLanguage(rawValue: rawValue) {
                    viewModel.saveLanguage(language)
                }
            }
        )
    }
}
