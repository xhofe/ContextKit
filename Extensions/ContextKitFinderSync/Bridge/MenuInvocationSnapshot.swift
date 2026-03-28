import ContextKitCore
import Foundation

struct MenuInvocationSnapshot: Sendable {
    var selection: SelectionContext
    var nodes: [FinderMenuNode]
}

final class MenuInvocationCache {
    private let lock = NSLock()
    private var snapshot: MenuInvocationSnapshot?

    func update(selection: SelectionContext, nodes: [FinderMenuNode]) {
        lock.lock()
        defer { lock.unlock() }
        snapshot = MenuInvocationSnapshot(selection: selection, nodes: nodes)
    }

    func currentSnapshot() -> MenuInvocationSnapshot? {
        lock.lock()
        defer { lock.unlock() }
        return snapshot
    }
}
