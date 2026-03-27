import ContextKitCore
import Foundation

struct WorkflowDraftStep: Identifiable, Hashable {
    var id = UUID()
    var actionID: String
    var input: WorkflowStepInput
}
