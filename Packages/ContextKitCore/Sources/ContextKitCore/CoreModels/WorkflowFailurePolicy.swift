import Foundation

public enum WorkflowFailurePolicy: String, Codable, CaseIterable, Sendable {
    case stopOnFailure
    case continueWithWarning
}
