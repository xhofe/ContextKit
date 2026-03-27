import Foundation

public struct ActionResultPolicy: Codable, Hashable, Sendable {
    public var deliversClipboard: Bool
    public var deliversFiles: Bool
    public var deliversStructuredPayload: Bool
    public var showsUserMessage: Bool

    public init(
        deliversClipboard: Bool = false,
        deliversFiles: Bool = false,
        deliversStructuredPayload: Bool = false,
        showsUserMessage: Bool = true
    ) {
        self.deliversClipboard = deliversClipboard
        self.deliversFiles = deliversFiles
        self.deliversStructuredPayload = deliversStructuredPayload
        self.showsUserMessage = showsUserMessage
    }
}
