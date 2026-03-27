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
            return NSMenu(title: L10n.string("finder.menu.title", fallback: "ContextKit"))
        }

        return menuBuilder.build(
            descriptors: descriptors,
            selection: selection,
            action: #selector(handleMenuItem(_:))
        )
    }

    @IBAction nonisolated func handleMenuItem(_ sender: Any?) {
        guard let targetId = Self.actionIdentifier(from: sender) else {
            NSLog("ContextKitFinderSync menu click missing action identifier")
            return
        }

        Task { @MainActor in
            Self.dispatchMenuAction(targetId: targetId)
        }
    }

    @MainActor
    private static func dispatchMenuAction(targetId: String) {
        let selectionContextReader = SelectionContextReader()
        let cache = MenuDescriptorCache()
        let dispatcher = ExtensionActionDispatcher()
        let controller = FIFinderSyncController.default()
        guard let selection = selectionContextReader.read(from: controller) else {
            NSLog("ContextKitFinderSync could not resolve current selection for target: %@", targetId)
            return
        }

        guard let descriptor = descriptor(for: targetId, cache: cache) else {
            NSLog("ContextKitFinderSync missing descriptor for target: %@", targetId)
            return
        }

        let request = ExecutionRequest(
            targetId: descriptor.id,
            targetType: descriptor.targetType,
            selectedURLs: selection.selectedURLs,
            invocationSource: .finder,
            monitoredRootURL: selection.monitoredRootURL
        )

        do {
            try dispatcher.dispatch(request)
            NSLog("ContextKitFinderSync dispatched request: %@", request.targetId)
        } catch {
            NSLog(
                "ContextKitFinderSync failed to dispatch request %@: %@",
                request.targetId,
                error.localizedDescription
            )
        }
    }

    private func syncObservedDirectories() {
        guard let settings = try? settingsStore.load() else {
            return
        }
        FIFinderSyncController.default().directoryURLs = Set(settings.monitoredRoots.map(\.url))
    }

    nonisolated private static func actionIdentifier(from sender: Any?) -> String? {
        guard let object = sender as AnyObject?,
              let representedObject = object.value(forKey: "representedObject") else {
            return nil
        }

        if let identifier = representedObject as? String, !identifier.isEmpty {
            return identifier
        }

        if let identifier = representedObject as? NSString {
            let value = identifier as String
            if !value.isEmpty {
                return value
            }
        }

        return nil
    }

    private static func descriptor(for targetId: String, cache: MenuDescriptorCache) -> MenuDescriptor? {
        guard let descriptors = try? cache.load() else {
            return nil
        }
        return descriptors.first { $0.id == targetId }
    }
}
