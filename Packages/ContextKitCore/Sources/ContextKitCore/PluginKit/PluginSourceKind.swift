import Foundation

public enum PluginSourceKind: String, Codable, Sendable {
    case bundled
    case local
    case git
}
