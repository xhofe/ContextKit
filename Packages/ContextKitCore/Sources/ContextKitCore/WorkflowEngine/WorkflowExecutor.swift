import Foundation
import ContextKitPluginSDK

public final class WorkflowExecutor: Sendable {
    private let inputResolver: WorkflowInputResolver

    public init(inputResolver: WorkflowInputResolver = WorkflowInputResolver()) {
        self.inputResolver = inputResolver
    }

    public func execute(
        workflow: WorkflowManifest,
        initialRequest: ExecutionRequest,
        runStep: (ExecutionRequest) throws -> ExecutionResult
    ) throws -> ExecutionResult {
        var previousResult: ExecutionResult?
        var aggregatedLogs: [ExecutionLogLine] = []

        for step in workflow.steps {
            let resolvedInput = inputResolver.resolve(
                stepInput: step.input,
                initialSelection: initialRequest.selectedURLs,
                previousResult: previousResult
            )

            var stepEnvironment = initialRequest.environmentOverrides
            if let previousText = resolvedInput.previousText {
                stepEnvironment[PluginEnvironment.previousClipboardText] = previousText
            }
            if let previousResult {
                let payloadData = try JSONEncoder().encode(previousResult.structuredPayload)
                stepEnvironment[PluginEnvironment.previousStructuredPayloadJSON] = String(decoding: payloadData, as: UTF8.self)
            }

            let stepRequest = ExecutionRequest(
                targetId: step.actionID,
                targetType: .action,
                selectedURLs: resolvedInput.selectedURLs,
                invocationSource: initialRequest.invocationSource,
                monitoredRootURL: initialRequest.monitoredRootURL,
                environmentOverrides: stepEnvironment
            )

            do {
                previousResult = try runStep(stepRequest)
                if let previousResult {
                    aggregatedLogs.append(contentsOf: previousResult.logs)
                }
            } catch {
                guard workflow.failurePolicy == .continueWithWarning else {
                    throw error
                }

                aggregatedLogs.append(
                    ExecutionLogLine(
                        level: "warning",
                        message: L10n.string(
                            "workflow.log.stepFailed",
                            fallback: "Step %@ failed: %@",
                            step.actionID,
                            error.localizedDescription
                        )
                    )
                )
            }
        }

        return ExecutionResult(
            status: previousResult?.status ?? .skipped,
            message: previousResult?.message ?? L10n.string("workflow.result.noResult", fallback: "Workflow completed with no result."),
            producedURLs: previousResult?.producedURLs ?? [],
            clipboardText: previousResult?.clipboardText,
            structuredPayload: previousResult?.structuredPayload ?? [:],
            logs: aggregatedLogs + (previousResult?.logs ?? [])
        )
    }
}
