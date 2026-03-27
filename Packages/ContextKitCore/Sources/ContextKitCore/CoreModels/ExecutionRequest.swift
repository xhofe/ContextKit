import Foundation

public struct ExecutionRequest: Codable, Hashable, Sendable {
    public var targetId: String
    public var targetType: TargetType
    public var selectedURLs: [URL]
    public var invocationSource: InvocationSource
    public var monitoredRootURL: URL?
    public var environmentOverrides: [String: String]

    public init(
        targetId: String,
        targetType: TargetType,
        selectedURLs: [URL],
        invocationSource: InvocationSource,
        monitoredRootURL: URL?,
        environmentOverrides: [String: String] = [:]
    ) {
        self.targetId = targetId
        self.targetType = targetType
        self.selectedURLs = selectedURLs
        self.invocationSource = invocationSource
        self.monitoredRootURL = monitoredRootURL
        self.environmentOverrides = environmentOverrides
    }
}
