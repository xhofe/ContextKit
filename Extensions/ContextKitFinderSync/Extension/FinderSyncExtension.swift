import AppKit
import ContextKitCore
import FinderSync
import Foundation

final class FinderSyncExtension: FIFinderSync {
    private let settingsStore = SharedSettingsStore()
    private let cache = MenuDescriptorCache()
    private let selectionContextReader = SelectionContextReader()
    private let menuBuilder = MenuBuilder()
    private let dispatcher = ExtensionActionDispatcher()

    override init() {
        super.init()
        syncObservedDirectories()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        syncObservedDirectories()
        let controller = FIFinderSyncController.default()
        guard let selection = selectionContextReader.read(from: controller),
              let descriptors = try? cache.load() else {
            return NSMenu(title: "ContextKit")
        }

        return menuBuilder.build(
            descriptors: descriptors,
            selection: selection,
            target: self,
            action: #selector(handleMenuItem(_:))
        )
    }

    @objc private func handleMenuItem(_ sender: NSMenuItem) {
        guard let payload = sender.representedObject as? MenuInvocationPayload else {
            return
        }
        dispatcher.dispatch(payload.request)
    }

    private func syncObservedDirectories() {
        guard let settings = try? settingsStore.load() else {
            return
        }
        FIFinderSyncController.default().directoryURLs = Set(settings.monitoredRoots.map(\.url))
    }
}
