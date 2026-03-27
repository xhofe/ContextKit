import Foundation
import UniformTypeIdentifiers

public struct ContextSnapshot: Hashable, Sendable {
    public var selectedURLs: [URL]
    public var monitoredRootURL: URL?
    public var uniformTypeIdentifiers: [String]
    public var containsFiles: Bool
    public var containsDirectories: Bool
    public var allWithinMonitoredRoot: Bool

    public init(selectedURLs: [URL], monitoredRootURL: URL?) {
        let normalizedRoot = monitoredRootURL?.standardizedFileURL
        let normalizedSelection = selectedURLs.map(\.standardizedFileURL)
        self.selectedURLs = normalizedSelection
        self.monitoredRootURL = normalizedRoot
        self.uniformTypeIdentifiers = selectedURLs.compactMap(Self.uniformTypeIdentifier(for:))
        self.containsFiles = selectedURLs.contains { !$0.hasDirectoryPath }
        self.containsDirectories = selectedURLs.contains(where: \.hasDirectoryPath)
        self.allWithinMonitoredRoot = normalizedSelection.allSatisfy { url in
            guard let normalizedRoot else { return false }
            return url.standardizedFileURL.path.hasPrefix(normalizedRoot.path)
        }
    }

    public var selectionCount: Int {
        selectedURLs.count
    }

    private static func uniformTypeIdentifier(for url: URL) -> String? {
        guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]),
              let contentType = resourceValues.contentType else {
            return UTType(filenameExtension: url.pathExtension)?.identifier
        }

        return contentType.identifier
    }
}
