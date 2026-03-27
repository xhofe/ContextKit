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
            return "Overview"
        case .actions:
            return "Actions"
        case .plugins:
            return "Plugins"
        case .workflows:
            return "Workflows"
        case .settings:
            return "Settings"
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
