import Foundation

public enum ActionCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case open
    case tools
    case intelligent
    case custom

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .open:
            return L10n.string("action.category.open", fallback: "Open")
        case .tools:
            return L10n.string("action.category.tools", fallback: "Tools")
        case .intelligent:
            return L10n.string("action.category.intelligent", fallback: "Intelligent")
        case .custom:
            return L10n.string("action.category.custom", fallback: "Custom")
        }
    }
}
