import Foundation

public enum InvocationSource: String, Codable, Sendable {
    case finder
    case app
    case cli
}
