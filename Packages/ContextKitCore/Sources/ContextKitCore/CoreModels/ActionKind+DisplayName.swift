import Foundation

public extension ActionKind {
    var displayName: String {
        switch self {
        case .builtin:
            return L10n.string("action.kind.builtin", fallback: "Built-in")
        case .shell:
            return L10n.string("action.kind.shell", fallback: "Shell")
        case .script:
            return L10n.string("action.kind.script", fallback: "Script")
        case .binary:
            return L10n.string("action.kind.binary", fallback: "Binary")
        case .plugin:
            return L10n.string("action.kind.plugin", fallback: "Plugin")
        }
    }
}
