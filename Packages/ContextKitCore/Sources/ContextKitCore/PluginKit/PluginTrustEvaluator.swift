import Foundation

public struct PluginTrustEvaluator: Sendable {
    public init() {}

    public func diff(for manifest: ActionManifest, grant: TrustedPluginGrant?) -> PluginCapabilityDiff {
        let requested = Set(manifest.capabilities)
        let granted = Set(grant?.capabilities ?? [])
        return PluginCapabilityDiff(
            added: Array(requested.subtracting(granted)).sorted(by: { $0.rawValue < $1.rawValue }),
            removed: Array(granted.subtracting(requested)).sorted(by: { $0.rawValue < $1.rawValue })
        )
    }

    public func requiresTrust(for manifest: ActionManifest, settings: AppSettings) -> Bool {
        let grant = settings.trustedPlugins.first(where: { $0.pluginID == manifest.id })
        return diff(for: manifest, grant: grant).hasChanges || grant == nil
    }
}
