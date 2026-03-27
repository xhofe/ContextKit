import Foundation

public struct TrustedPluginGrant: Codable, Hashable, Identifiable, Sendable {
    public var id: String { pluginID }
    public var pluginID: String
    public var capabilities: [Capability]
    public var grantedAt: Date
    public var sourceDescription: String
    public var revision: String?

    public init(
        pluginID: String,
        capabilities: [Capability],
        grantedAt: Date = .now,
        sourceDescription: String,
        revision: String? = nil
    ) {
        self.pluginID = pluginID
        self.capabilities = capabilities
        self.grantedAt = grantedAt
        self.sourceDescription = sourceDescription
        self.revision = revision
    }
}
