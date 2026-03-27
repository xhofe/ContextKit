import Foundation

public enum ActionCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case open
    case tools
    case intelligent
    case custom

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .open:
            return "打开类"
        case .tools:
            return "工具类"
        case .intelligent:
            return "智能操作"
        case .custom:
            return "自定义"
        }
    }
}
