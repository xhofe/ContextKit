import Foundation

public struct ResolvedWorkflowInput: Sendable {
    public var selectedURLs: [URL]
    public var previousText: String?

    public init(selectedURLs: [URL], previousText: String? = nil) {
        self.selectedURLs = selectedURLs
        self.previousText = previousText
    }
}

public struct WorkflowInputResolver: Sendable {
    public init() {}

    public func resolve(
        stepInput: WorkflowStepInput,
        initialSelection: [URL],
        previousResult: ExecutionResult?
    ) -> ResolvedWorkflowInput {
        switch stepInput {
        case .selection:
            return ResolvedWorkflowInput(selectedURLs: initialSelection)
        case .previousFiles:
            return ResolvedWorkflowInput(selectedURLs: previousResult?.producedURLs ?? [])
        case .previousText:
            return ResolvedWorkflowInput(
                selectedURLs: [],
                previousText: previousResult?.clipboardText ?? previousResult?.message
            )
        }
    }
}
