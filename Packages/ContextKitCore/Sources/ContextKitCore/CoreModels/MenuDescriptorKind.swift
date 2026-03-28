import Foundation

public enum MenuDescriptorKind: String, Codable, Hashable, Sendable {
    case group
    case action
    case workflow
}
