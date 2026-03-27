import ContextKitCore
import Foundation

struct RunActionCommand {
    let environment: CLIEnvironment

    func execute(arguments: ArraySlice<String>) throws -> ExecutionResult {
        guard let actionID = arguments.first else {
            throw CLIError.usage("contextkit run <action-id> <path...>")
        }

        let paths = Array(arguments.dropFirst())
        let selectedURLs = paths.map(URL.init(fileURLWithPath:))
        let settings = try environment.settingsStore.load()
        let monitoredRoot = settings.monitoredRoot(for: selectedURLs.first)

        return try environment.executionCoordinator.execute(
            ExecutionRequest(
                targetId: actionID,
                targetType: .action,
                selectedURLs: selectedURLs,
                invocationSource: .cli,
                monitoredRootURL: monitoredRoot
            )
        )
    }
}
