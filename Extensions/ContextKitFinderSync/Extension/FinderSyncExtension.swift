import AppKit
import ContextKitCore
import FinderSync
import Foundation

final class FinderSyncExtension: FIFinderSync {
    private let settingsStore = SharedSettingsStore()
    private let cache = MenuDescriptorCache()
    private let selectionContextReader = SelectionContextReader()
    private let menuBuilder = MenuBuilder()

    override init() {
        super.init()
        syncObservedDirectories()
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        syncObservedDirectories()
        let controller = FIFinderSyncController.default()
        guard let selection = selectionContextReader.read(from: controller),
              let descriptors = try? cache.load() else {
            return NSMenu(title: L10n.string("finder.menu.title", fallback: "ContextKit"))
        }

        return menuBuilder.build(
            descriptors: descriptors,
            selection: selection,
            target: MenuActionHandler.shared,
            action: #selector(MenuActionHandler.handleMenuItem(_:))
        )
    }

    private func syncObservedDirectories() {
        guard let settings = try? settingsStore.load() else {
            return
        }
        FIFinderSyncController.default().directoryURLs = Set(settings.monitoredRoots.map(\.url))
    }
}
