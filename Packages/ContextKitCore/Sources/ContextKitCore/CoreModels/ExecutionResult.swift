import Foundation

public struct ExecutionResult: Codable, Hashable, Sendable {
    public var status: ExecutionStatus
    public var message: String
    public var producedURLs: [URL]
    public var clipboardText: String?
    public var structuredPayload: [String: String]
    public var logs: [ExecutionLogLine]

    public init(
        status: ExecutionStatus,
        message: String,
        producedURLs: [URL] = [],
        clipboardText: String? = nil,
        structuredPayload: [String: String] = [:],
        logs: [ExecutionLogLine] = []
    ) {
        self.status = status
        self.message = message
        self.producedURLs = producedURLs
        self.clipboardText = clipboardText
        self.structuredPayload = structuredPayload
        self.logs = logs
    }
}
