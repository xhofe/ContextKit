import Foundation

enum LocalizationBundleResolver {
    static func bundle(for language: AppLanguage, resourceBundle: Bundle = .module) -> Bundle {
        guard let localization = localizationIdentifier(for: language, in: resourceBundle),
              let localizedBundle = localizedBundle(for: localization, in: resourceBundle) else {
            return resourceBundle
        }

        return localizedBundle
    }

    static func locale(for language: AppLanguage) -> Locale {
        switch language {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .simplifiedChinese:
            return Locale(identifier: "zh-Hans")
        }
    }

    private static func localizationIdentifier(for language: AppLanguage, in resourceBundle: Bundle) -> String? {
        switch language {
        case .system:
            let availableLocalizations = resourceBundle.localizations.filter { $0 != "Base" }
            return Bundle.preferredLocalizations(
                from: availableLocalizations,
                forPreferences: Locale.preferredLanguages
            ).first
        case .english, .simplifiedChinese:
            return resourceLocalization(for: language)
        }
    }

    private static func localizedBundle(for localization: String, in resourceBundle: Bundle) -> Bundle? {
        let matchingLocalization = resourceBundle.localizations.first {
            $0.caseInsensitiveCompare(localization) == .orderedSame
        } ?? localization

        guard let path = resourceBundle.path(forResource: matchingLocalization, ofType: "lproj") else {
            return nil
        }

        return Bundle(path: path)
    }

    private static func resourceLocalization(for language: AppLanguage) -> String {
        switch language {
        case .system:
            return "en"
        case .english:
            return "en"
        case .simplifiedChinese:
            return "zh-Hans"
        }
    }
}
