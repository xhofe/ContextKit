import Foundation
import Testing
@testable import ContextKitCore

@Test
func workflowExecutorUsesPreviousResultFiles() throws {
    let workflow = WorkflowManifest(
        id: "workflow.sample",
        name: "Sample",
        steps: [
            WorkflowStep(actionID: "step.one", input: .selection),
            WorkflowStep(actionID: "step.two", input: .previousFiles),
        ],
        failurePolicy: .stopOnFailure
    )

    let request = ExecutionRequest(
        targetId: workflow.id,
        targetType: .workflow,
        selectedURLs: [URL(fileURLWithPath: "/tmp/in.txt")],
        invocationSource: .cli,
        monitoredRootURL: URL(fileURLWithPath: "/tmp", isDirectory: true)
    )

    var capturedSecondStepSelection: [URL] = []
    let executor = WorkflowExecutor()

    _ = try executor.execute(workflow: workflow, initialRequest: request) { stepRequest in
        if stepRequest.targetId == "step.one" {
            return ExecutionResult(
                status: .success,
                message: "step one",
                producedURLs: [URL(fileURLWithPath: "/tmp/out.txt")]
            )
        }

        capturedSecondStepSelection = stepRequest.selectedURLs
        return ExecutionResult(status: .success, message: "step two")
    }

    #expect(capturedSecondStepSelection == [URL(fileURLWithPath: "/tmp/out.txt")])
}
