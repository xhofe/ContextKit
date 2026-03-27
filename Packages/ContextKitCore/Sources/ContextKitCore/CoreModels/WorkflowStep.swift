import Foundation

public struct WorkflowStep: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var actionID: String
    public var input: WorkflowStepInput

    public init(id: UUID = UUID(), actionID: String, input: WorkflowStepInput) {
        self.id = id
        self.actionID = actionID
        self.input = input
    }
}
