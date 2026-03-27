import Foundation

public struct PluginCapabilityDiff: Hashable, Sendable {
    public var added: [Capability]
    public var removed: [Capability]

    public init(added: [Capability], removed: [Capability]) {
        self.added = added
        self.removed = removed
    }

    public var hasChanges: Bool {
        !added.isEmpty || !removed.isEmpty
    }
}
