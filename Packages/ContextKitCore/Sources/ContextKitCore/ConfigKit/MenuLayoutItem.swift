import Foundation

public struct MenuLayoutItem: Codable, Hashable, Identifiable, Sendable {
    public enum Kind: String, Codable, Hashable, Sendable {
        case group
        case action
        case workflow
    }

    public var id: String
    public var kind: Kind
    public var title: String?
    public var children: [MenuLayoutItem]

    public init(
        id: String,
        kind: Kind,
        title: String? = nil,
        children: [MenuLayoutItem] = []
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.children = children
    }

    public var isGroup: Bool {
        kind == .group
    }

    public static func group(
        id: String = "group.\(UUID().uuidString.lowercased())",
        title: String,
        children: [MenuLayoutItem] = []
    ) -> MenuLayoutItem {
        MenuLayoutItem(id: id, kind: .group, title: title, children: children)
    }

    public static func action(_ actionID: String) -> MenuLayoutItem {
        MenuLayoutItem(id: actionID, kind: .action)
    }

    public static func workflow(_ workflowID: String) -> MenuLayoutItem {
        MenuLayoutItem(id: workflowID, kind: .workflow)
    }
}
