import Foundation

public enum L10n {
    public static func string(_ key: String, fallback: String) -> String {
        NSLocalizedString(key, bundle: .module, value: fallback, comment: "")
    }

    public static func string(_ key: String, fallback: String, _ arguments: CVarArg...) -> String {
        string(key, fallback: fallback, arguments: arguments)
    }

    public static func string(_ key: String, fallback: String, arguments: [CVarArg]) -> String {
        let format = string(key, fallback: fallback)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}
