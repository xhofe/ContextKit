import Foundation

public enum ExecutionStatus: String, Codable, Sendable {
    case queued
    case success
    case failure
    case skipped
}
