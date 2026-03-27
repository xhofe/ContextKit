import Foundation

public extension WorkflowStepInput {
    var displayName: String {
        switch self {
        case .selection:
            return L10n.string("workflow.input.selection", fallback: "Selection")
        case .previousFiles:
            return L10n.string("workflow.input.previousFiles", fallback: "Previous Files")
        case .previousText:
            return L10n.string("workflow.input.previousText", fallback: "Previous Text")
        }
    }
}
