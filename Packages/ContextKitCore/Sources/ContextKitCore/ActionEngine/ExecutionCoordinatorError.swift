import Foundation

public enum ExecutionCoordinatorError: LocalizedError {
    case unknownAction(String)
    case unknownWorkflow(String)
    case untrustedPlugin(String)
    case invalidPluginEntrypoint(String)
    case processFailed(String)

    public var errorDescription: String? {
        switch self {
        case let .unknownAction(identifier):
            return L10n.string("core.error.unknownAction", fallback: "Unknown action: %@", identifier)
        case let .unknownWorkflow(identifier):
            return L10n.string("core.error.unknownWorkflow", fallback: "Unknown workflow: %@", identifier)
        case let .untrustedPlugin(identifier):
            return L10n.string("core.error.untrustedPlugin", fallback: "Plugin %@ requires explicit trust before it can run.", identifier)
        case let .invalidPluginEntrypoint(identifier):
            return L10n.string("core.error.invalidPluginEntrypoint", fallback: "Plugin %@ is missing a valid entrypoint.", identifier)
        case let .processFailed(message):
            return message
        }
    }
}
