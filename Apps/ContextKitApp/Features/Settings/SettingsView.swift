import ContextKitCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            monitoredRootsSection
            finderSection
            terminalMenuSection
            editorMenuSection
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

    private var terminalMenuSection: some View {
        Section(L10n.string("app.settings.terminalMenu", fallback: "Terminal Menu")) {
            Text(
                L10n.string(
                    "app.settings.terminalMenuHint",
                    fallback: "ContextKit shows a terminal submenu in Finder. Choose which terminal apps should appear there."
                )
            )
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            ForEach(viewModel.terminalChoices) { launcher in
                Toggle(
                    launcher.name,
                    isOn: Binding(
                        get: { viewModel.isTerminalVisible(launcher) },
                        set: { viewModel.setTerminalVisibility($0, for: launcher) }
                    )
                )
            }
        }
    }

    private var editorMenuSection: some View {
        Section(L10n.string("app.settings.editorMenu", fallback: "Editor Menu")) {
            Text(
                L10n.string(
                    "app.settings.editorMenuHint",
                    fallback: "ContextKit shows an editor submenu in Finder. Choose which editors should appear there."
                )
            )
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            ForEach(viewModel.editorChoices) { launcher in
                Toggle(
                    launcher.name,
                    isOn: Binding(
                        get: { viewModel.isEditorVisible(launcher) },
                        set: { viewModel.setEditorVisibility($0, for: launcher) }
                    )
                )
            }
        }
    }

    private var finderSection: some View {
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
                action: viewModel.openFinderExtensionsSettings
            )
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
