import Foundation

public enum ActionKind: String, Codable, Sendable {
    case builtin
    case shell
    case script
    case binary
    case plugin
}
