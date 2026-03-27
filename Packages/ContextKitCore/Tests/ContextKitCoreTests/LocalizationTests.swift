import Foundation
import Testing
@testable import ContextKitCore

@Test
func appSettingsDefaultsLanguageToSystemWhenDecodingOlderPayload() throws {
    let legacyJSON = """
    {
      "defaultEditor": {
        "bundleIdentifier": "com.microsoft.VSCode",
        "id": "editor.vscode",
        "name": "Visual Studio Code"
      },
      "defaultTerminal": {
        "bundleIdentifier": "com.apple.Terminal",
        "id": "terminal.system",
        "name": "Terminal"
      },
      "disabledActionIDs": [],
      "monitoredRoots": [],
      "orderedActionIDs": [],
      "trustedPlugins": []
    }
    """

    let settings = try JSONDecoder().decode(AppSettings.self, from: Data(legacyJSON.utf8))

    #expect(settings.language == .system)
}

@Test
func localizationBundleResolverLoadsExplicitChineseStrings() {
    let bundle = LocalizationBundleResolver.bundle(for: .simplifiedChinese)
    let value = bundle.localizedString(forKey: "app.settings.navigation", value: nil, table: nil)

    #expect(value == "设置")
}
