import ContextKitCore
import Foundation

struct RunWorkflowCommand {
    let environment: CLIEnvironment

    func execute(arguments: ArraySlice<String>) throws -> ExecutionResult {
        guard let workflowID = arguments.first else {
            throw CLIError.usage("contextkit workflow run <workflow-id> <path...>")
        }

        let paths = Array(arguments.dropFirst())
        let selectedURLs = paths.map(URL.init(fileURLWithPath:))
        let settings = try environment.settingsStore.load()
        let monitoredRoot = settings.monitoredRoot(for: selectedURLs.first)

        return try environment.executionCoordinator.execute(
            ExecutionRequest(
                targetId: workflowID,
                targetType: .workflow,
                selectedURLs: selectedURLs,
                invocationSource: .cli,
                monitoredRootURL: monitoredRoot
            )
        )
    }
}
