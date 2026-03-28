import ContextKitCore
import SwiftUI

struct LanguageSectionView: View {
    let viewModel: SettingsViewModel
    @State private var selectedLanguage: AppLanguage

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        _selectedLanguage = State(initialValue: viewModel.settings.language)
    }

    var body: some View {
        Section(L10n.string("app.settings.localization", fallback: "Localization")) {
            Picker(
                L10n.string("app.settings.language", fallback: "Language"),
                selection: $selectedLanguage
            ) {
                Text(AppLanguage.system.displayName).tag(AppLanguage.system)
                Text(AppLanguage.english.displayName).tag(AppLanguage.english)
                Text(AppLanguage.simplifiedChinese.displayName).tag(AppLanguage.simplifiedChinese)
            }
        }
        .onChange(of: viewModel.settings.language) { _, newValue in
            selectedLanguage = newValue
        }
        .onChange(of: selectedLanguage) { _, newValue in
            viewModel.saveLanguage(newValue)
        }
    }
}
