import Foundation

public struct WorkflowManifest: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var name: String
    public var steps: [WorkflowStep]
    public var failurePolicy: WorkflowFailurePolicy
    public var finalResultPolicy: ActionResultPolicy

    public init(
        id: String,
        name: String,
        steps: [WorkflowStep],
        failurePolicy: WorkflowFailurePolicy,
        finalResultPolicy: ActionResultPolicy = ActionResultPolicy()
    ) {
        self.id = id
        self.name = name
        self.steps = steps
        self.failurePolicy = failurePolicy
        self.finalResultPolicy = finalResultPolicy
    }
}
