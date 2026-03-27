import Foundation

public enum ManifestError: LocalizedError {
    case missingManifest(URL)
    case invalidManifest(URL, String)
    case missingEntrypoint(String)
    case invalidWorkflow(String)

    public var errorDescription: String? {
        switch self {
        case let .missingManifest(url):
            return L10n.string("core.error.missingManifest", fallback: "Missing manifest at %@.", url.path)
        case let .invalidManifest(url, reason):
            return L10n.string("core.error.invalidManifest", fallback: "Invalid manifest at %@: %@", url.path, reason)
        case let .missingEntrypoint(pluginID):
            return L10n.string("core.error.missingEntrypoint", fallback: "Plugin %@ is missing an executable entrypoint.", pluginID)
        case let .invalidWorkflow(identifier):
            return L10n.string("core.error.invalidWorkflow", fallback: "Workflow %@ is invalid.", identifier)
        }
    }
}
