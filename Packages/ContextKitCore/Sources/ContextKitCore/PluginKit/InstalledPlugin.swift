import Foundation

public struct InstalledPlugin: Identifiable, Sendable {
    public var id: String { package.manifest.id }
    public var package: PluginPackage
    public var installationRecord: PluginInstallationRecord
    public var trustDiff: PluginCapabilityDiff

    public init(package: PluginPackage, installationRecord: PluginInstallationRecord, trustDiff: PluginCapabilityDiff) {
        self.package = package
        self.installationRecord = installationRecord
        self.trustDiff = trustDiff
    }

    public var isTrusted: Bool {
        !trustDiff.hasChanges
    }
}
