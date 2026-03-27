import Foundation

public struct MenuDescriptor: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var category: ActionCategory
    public var targetType: TargetType
    public var contextRules: ContextRules
    public var isEnabled: Bool
    public var sortOrder: Int

    public init(
        id: String,
        title: String,
        category: ActionCategory,
        targetType: TargetType,
        contextRules: ContextRules,
        isEnabled: Bool,
        sortOrder: Int
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.targetType = targetType
        self.contextRules = contextRules
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
    }
}
