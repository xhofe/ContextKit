import Foundation

public struct PluginPackage: Sendable {
    public static let manifestName = "contextkit.plugin.json"
    public static let installationRecordName = ".contextkit-installation.json"

    public var rootURL: URL
    public var manifest: ActionManifest
    public var entrypointURL: URL?

    public init(rootURL: URL, manifest: ActionManifest, entrypointURL: URL?) {
        self.rootURL = rootURL
        self.manifest = manifest
        self.entrypointURL = entrypointURL
    }

    public static func load(from rootURL: URL, loader: ActionManifestLoader = ActionManifestLoader()) throws -> PluginPackage {
        let manifestURL = rootURL.appending(path: manifestName)
        let manifest = try loader.load(from: manifestURL)
        let entrypointURL = manifest.entrypoint.map { rootURL.appending(path: $0) }
        return PluginPackage(rootURL: rootURL, manifest: manifest, entrypointURL: entrypointURL)
    }

    public var installationRecordURL: URL {
        rootURL.appending(path: Self.installationRecordName)
    }
}
