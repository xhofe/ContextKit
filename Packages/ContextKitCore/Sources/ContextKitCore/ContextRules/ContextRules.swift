import Foundation
import UniformTypeIdentifiers

public struct ContextRules: Codable, Hashable, Sendable {
    public var allowFiles: Bool
    public var allowDirectories: Bool
    public var minSelection: Int
    public var maxSelection: Int?
    public var requireSameRoot: Bool
    public var allowedUTTypes: [String]

    public init(
        allowFiles: Bool = true,
        allowDirectories: Bool = true,
        minSelection: Int = 1,
        maxSelection: Int? = nil,
        requireSameRoot: Bool = false,
        allowedUTTypes: [String] = []
    ) {
        self.allowFiles = allowFiles
        self.allowDirectories = allowDirectories
        self.minSelection = minSelection
        self.maxSelection = maxSelection
        self.requireSameRoot = requireSameRoot
        self.allowedUTTypes = allowedUTTypes
    }

    public func matches(snapshot: ContextSnapshot) -> Bool {
        guard snapshot.selectionCount >= minSelection else {
            return false
        }

        if let maxSelection, snapshot.selectionCount > maxSelection {
            return false
        }

        if !allowFiles && snapshot.containsFiles {
            return false
        }

        if !allowDirectories && snapshot.containsDirectories {
            return false
        }

        if requireSameRoot && !snapshot.allWithinMonitoredRoot {
            return false
        }

        guard !allowedUTTypes.isEmpty else {
            return true
        }

        return snapshot.uniformTypeIdentifiers.contains { identifier in
            allowedUTTypes.contains { candidate in
                guard let type = UTType(identifier),
                      let allowed = UTType(candidate) else {
                    return identifier == candidate
                }

                return type.conforms(to: allowed)
            }
        }
    }
}
