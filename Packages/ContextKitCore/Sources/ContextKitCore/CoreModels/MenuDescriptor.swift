import Foundation

public struct MenuDescriptor: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var kind: MenuDescriptorKind
    public var category: ActionCategory
    public var targetType: TargetType?
    public var contextRules: ContextRules
    public var isEnabled: Bool
    public var sortOrder: Int
    public var parentID: String?

    public init(
        id: String,
        title: String,
        kind: MenuDescriptorKind,
        category: ActionCategory,
        targetType: TargetType?,
        contextRules: ContextRules,
        isEnabled: Bool,
        sortOrder: Int,
        parentID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.category = category
        self.targetType = targetType
        self.contextRules = contextRules
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.parentID = parentID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case kind
        case category
        case targetType
        case contextRules
        case isEnabled
        case sortOrder
        case parentID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decodeIfPresent(ActionCategory.self, forKey: .category) ?? .custom
        targetType = try container.decodeIfPresent(TargetType.self, forKey: .targetType)
        contextRules = try container.decodeIfPresent(ContextRules.self, forKey: .contextRules) ?? ContextRules()
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        parentID = try container.decodeIfPresent(String.self, forKey: .parentID)

        if let decodedKind = try container.decodeIfPresent(MenuDescriptorKind.self, forKey: .kind) {
            kind = decodedKind
        } else if let targetType {
            kind = targetType == .workflow ? .workflow : .action
        } else {
            kind = .group
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(kind, forKey: .kind)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(targetType, forKey: .targetType)
        try container.encode(contextRules, forKey: .contextRules)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encodeIfPresent(parentID, forKey: .parentID)
    }
}
