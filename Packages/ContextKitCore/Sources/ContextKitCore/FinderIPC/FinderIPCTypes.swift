import Foundation

public struct FinderSelectionRequest: Codable, Hashable, Sendable {
    public var selectedPaths: [String]
    public var targetedPath: String?
    public var currentDirectoryPath: String?

    public init(
        selectedPaths: [String],
        targetedPath: String?,
        currentDirectoryPath: String?
    ) {
        self.selectedPaths = selectedPaths
        self.targetedPath = targetedPath
        self.currentDirectoryPath = currentDirectoryPath
    }

    public var selectedURLs: [URL] {
        selectedPaths.map(URL.init(fileURLWithPath:))
    }

    public var effectiveSelectionURLs: [URL] {
        if !selectedPaths.isEmpty {
            return selectedURLs
        }

        if let targetedPath {
            return [URL(fileURLWithPath: targetedPath)]
        }

        return []
    }
}

public enum FinderMenuNodeKind: String, Codable, Hashable, Sendable {
    case group
    case action
    case workflow
    case message
}

public struct FinderMenuNode: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var kind: FinderMenuNodeKind
    public var targetType: TargetType?
    public var enabled: Bool
    public var children: [FinderMenuNode]

    public init(
        id: String,
        title: String,
        kind: FinderMenuNodeKind,
        targetType: TargetType? = nil,
        enabled: Bool = true,
        children: [FinderMenuNode] = []
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.targetType = targetType
        self.enabled = enabled
        self.children = children
    }
}

public struct FinderObservedRootsResponse: Codable, Hashable, Sendable {
    public var paths: [String]

    public init(paths: [String]) {
        self.paths = paths
    }
}

public struct FinderExecutionRequest: Codable, Hashable, Sendable {
    public var targetID: String
    public var targetType: TargetType
    public var selectedPaths: [String]
    public var targetedPath: String?
    public var currentDirectoryPath: String?

    public init(
        targetID: String,
        targetType: TargetType,
        selectedPaths: [String],
        targetedPath: String?,
        currentDirectoryPath: String?
    ) {
        self.targetID = targetID
        self.targetType = targetType
        self.selectedPaths = selectedPaths
        self.targetedPath = targetedPath
        self.currentDirectoryPath = currentDirectoryPath
    }

    public var effectiveSelectionURLs: [URL] {
        FinderSelectionRequest(
            selectedPaths: selectedPaths,
            targetedPath: targetedPath,
            currentDirectoryPath: currentDirectoryPath
        ).effectiveSelectionURLs
    }
}

public struct FinderExecutionResult: Codable, Hashable, Sendable {
    public var status: ExecutionStatus
    public var message: String

    public init(status: ExecutionStatus, message: String) {
        self.status = status
        self.message = message
    }

    public init(_ result: ExecutionResult) {
        self.status = result.status
        self.message = result.message
    }
}
