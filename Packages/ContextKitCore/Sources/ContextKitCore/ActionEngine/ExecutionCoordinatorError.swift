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
            return "Unknown action: \(identifier)"
        case let .unknownWorkflow(identifier):
            return "Unknown workflow: \(identifier)"
        case let .untrustedPlugin(identifier):
            return "Plugin \(identifier) requires explicit trust before it can run."
        case let .invalidPluginEntrypoint(identifier):
            return "Plugin \(identifier) is missing a valid entrypoint."
        case let .processFailed(message):
            return message
        }
    }
}
