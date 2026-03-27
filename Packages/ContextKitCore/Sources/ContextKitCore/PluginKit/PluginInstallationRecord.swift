import Foundation

public struct PluginInstallationRecord: Codable, Hashable, Sendable {
    public var pluginID: String
    public var sourceKind: PluginSourceKind
    public var sourceDescription: String
    public var revision: String?
    public var installedAt: Date

    public init(
        pluginID: String,
        sourceKind: PluginSourceKind,
        sourceDescription: String,
        revision: String? = nil,
        installedAt: Date = .now
    ) {
        self.pluginID = pluginID
        self.sourceKind = sourceKind
        self.sourceDescription = sourceDescription
        self.revision = revision
        self.installedAt = installedAt
    }
}
