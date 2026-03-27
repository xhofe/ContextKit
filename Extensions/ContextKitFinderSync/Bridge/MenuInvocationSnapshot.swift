import ContextKitCore
import Foundation

struct MenuInvocationSnapshot: Sendable {
    var selection: SelectionContext
    var descriptors: [MenuDescriptor]
}

final class MenuInvocationCache {
    private let lock = NSLock()
    private var snapshot: MenuInvocationSnapshot?

    func update(selection: SelectionContext, descriptors: [MenuDescriptor]) {
        lock.lock()
        defer { lock.unlock() }
        snapshot = MenuInvocationSnapshot(selection: selection, descriptors: descriptors)
    }

    func currentSnapshot() -> MenuInvocationSnapshot? {
        lock.lock()
        defer { lock.unlock() }
        return snapshot
    }
}
