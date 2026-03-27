import ContextKitCore
import Foundation

enum AppScreen: String, CaseIterable, Identifiable {
    case overview
    case actions
    case plugins
    case workflows
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview:
            return L10n.string("app.screen.overview", fallback: "Overview")
        case .actions:
            return L10n.string("app.screen.actions", fallback: "Actions")
        case .plugins:
            return L10n.string("app.screen.plugins", fallback: "Plugins")
        case .workflows:
            return L10n.string("app.screen.workflows", fallback: "Workflows")
        case .settings:
            return L10n.string("app.screen.settings", fallback: "Settings")
        }
    }

    var systemImage: String {
        switch self {
        case .overview:
            return "square.grid.2x2"
        case .actions:
            return "bolt.horizontal"
        case .plugins:
            return "puzzlepiece.extension"
        case .workflows:
            return "point.3.connected.trianglepath.dotted"
        case .settings:
            return "gearshape"
        }
    }
}
