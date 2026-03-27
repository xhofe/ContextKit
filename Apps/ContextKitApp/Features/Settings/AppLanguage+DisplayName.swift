import ContextKitCore
import Foundation

extension AppLanguage {
    var displayName: String {
        switch self {
        case .system:
            return L10n.string("app.settings.language.system", fallback: "System Default")
        case .english:
            return L10n.string("app.settings.language.english", fallback: "English")
        case .simplifiedChinese:
            return L10n.string("app.settings.language.simplifiedChinese", fallback: "Simplified Chinese")
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .simplifiedChinese:
            return Locale(identifier: "zh-Hans")
        }
    }
}
