import Foundation

public enum Capability: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case clipboard
    case notification
    case subprocess
    case network
    case git
    case writeGeneratedFiles
    case openApp

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .clipboard:
            return L10n.string("capability.clipboard", fallback: "Clipboard")
        case .notification:
            return L10n.string("capability.notification", fallback: "Notification")
        case .subprocess:
            return L10n.string("capability.subprocess", fallback: "Subprocess")
        case .network:
            return L10n.string("capability.network", fallback: "Network")
        case .git:
            return L10n.string("capability.git", fallback: "Git")
        case .writeGeneratedFiles:
            return L10n.string("capability.writeGeneratedFiles", fallback: "Write Generated Files")
        case .openApp:
            return L10n.string("capability.openApp", fallback: "Open Application")
        }
    }
}
