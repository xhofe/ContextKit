import Foundation

public struct ActionManifest: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var name: String
    public var category: ActionCategory
    public var kind: ActionKind
    public var contextRules: ContextRules
    public var capabilities: [Capability]
    public var entrypoint: String?
    public var argsTemplate: [String]
    public var resultPolicy: ActionResultPolicy

    public init(
        id: String,
        name: String,
        category: ActionCategory,
        kind: ActionKind,
        contextRules: ContextRules,
        capabilities: [Capability],
        entrypoint: String? = nil,
        argsTemplate: [String] = [],
        resultPolicy: ActionResultPolicy = ActionResultPolicy()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.kind = kind
        self.contextRules = contextRules
        self.capabilities = capabilities
        self.entrypoint = entrypoint
        self.argsTemplate = argsTemplate
        self.resultPolicy = resultPolicy
    }
}
