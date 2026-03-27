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
            return "Clipboard"
        case .notification:
            return "Notification"
        case .subprocess:
            return "Subprocess"
        case .network:
            return "Network"
        case .git:
            return "Git"
        case .writeGeneratedFiles:
            return "Write Generated Files"
        case .openApp:
            return "Open Application"
        }
    }
}
