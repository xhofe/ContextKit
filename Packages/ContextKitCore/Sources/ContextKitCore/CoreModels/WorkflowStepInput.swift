import Foundation

public enum WorkflowStepInput: String, Codable, CaseIterable, Sendable {
    case selection
    case previousFiles
    case previousText
}
