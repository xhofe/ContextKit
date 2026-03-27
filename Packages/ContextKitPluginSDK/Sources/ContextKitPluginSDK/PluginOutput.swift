import Foundation

public struct PluginOutput: Codable, Equatable, Sendable {
    public var message: String?
    public var clipboardText: String?
    public var producedPaths: [String]
    public var structuredPayload: [String: String]
    public var logLines: [String]

    public init(
        message: String? = nil,
        clipboardText: String? = nil,
        producedPaths: [String] = [],
        structuredPayload: [String: String] = [:],
        logLines: [String] = []
    ) {
        self.message = message
        self.clipboardText = clipboardText
        self.producedPaths = producedPaths
        self.structuredPayload = structuredPayload
        self.logLines = logLines
    }
}
