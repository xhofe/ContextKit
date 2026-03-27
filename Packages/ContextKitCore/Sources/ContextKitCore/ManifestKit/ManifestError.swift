import Foundation

public enum ManifestError: LocalizedError {
    case missingManifest(URL)
    case invalidManifest(URL, String)
    case missingEntrypoint(String)
    case invalidWorkflow(String)

    public var errorDescription: String? {
        switch self {
        case let .missingManifest(url):
            return "Missing manifest at \(url.path)."
        case let .invalidManifest(url, reason):
            return "Invalid manifest at \(url.path): \(reason)"
        case let .missingEntrypoint(pluginID):
            return "Plugin \(pluginID) is missing an executable entrypoint."
        case let .invalidWorkflow(identifier):
            return "Workflow \(identifier) is invalid."
        }
    }
}
