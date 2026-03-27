import ContextKitCore
import Foundation

struct WorkflowDraft {
    var id: String?
    var name: String
    var steps: [WorkflowDraftStep]

    init(id: String? = nil, name: String = "", steps: [WorkflowDraftStep] = []) {
        self.id = id
        self.name = name
        self.steps = steps
    }

    init(workflow: WorkflowManifest) {
        self.id = workflow.id
        self.name = workflow.name
        self.steps = workflow.steps.map { WorkflowDraftStep(actionID: $0.actionID, input: $0.input) }
    }
}
