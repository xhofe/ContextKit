import ContextKitCore
import Foundation

struct ActionListItem: Identifiable {
    let node: MenuLayoutItem
    let depth: Int
    let title: String
    let subtitle: String?
    let isEnabled: Bool

    var id: String { node.id }
    var isGroup: Bool { node.kind == .group }
    var isAction: Bool { node.kind == .action }
    var isWorkflow: Bool { node.kind == .workflow }
}
