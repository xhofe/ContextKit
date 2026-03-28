import ContextKitCore
import Foundation

struct MenuInvocationSnapshot: Sendable {
    var selection: SelectionContext
}

final class MenuInvocationCache {
    private let lock = NSLock()
    private var snapshot: MenuInvocationSnapshot?

    func update(selection: SelectionContext) {
        lock.lock()
        defer { lock.unlock() }
        snapshot = MenuInvocationSnapshot(selection: selection)
    }

    func currentSnapshot() -> MenuInvocationSnapshot? {
        lock.lock()
        defer { lock.unlock() }
        return snapshot
    }
}
