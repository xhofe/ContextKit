import Foundation

public enum L10n {
    public static func currentLanguage() -> AppLanguage {
        LocalizationPreferences.shared.currentLanguage()
    }

    public static func locale() -> Locale {
        LocalizationBundleResolver.locale(for: currentLanguage())
    }

    public static func invalidateCache() {
        LocalizationPreferences.shared.invalidate()
    }

    public static func string(_ key: String, fallback: String) -> String {
        let bundle = LocalizationBundleResolver.bundle(for: currentLanguage())
        return bundle.localizedString(forKey: key, value: fallback, table: nil)
    }

    public static func string(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
        string(key, fallback: fallback, arguments: arguments)
    }

    public static func string(_ key: String, fallback: String, arguments: [CVarArg]) -> String {
        let format = string(key, fallback: fallback)
        return String(format: format, locale: locale(), arguments: arguments)
    }
}
