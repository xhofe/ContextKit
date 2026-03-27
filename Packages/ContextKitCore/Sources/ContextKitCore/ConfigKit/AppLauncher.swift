import Foundation

public struct AppLauncher: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var bundleIdentifier: String?
    public var executablePath: String?

    public init(id: String, name: String, bundleIdentifier: String? = nil, executablePath: String? = nil) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.executablePath = executablePath
    }
}
