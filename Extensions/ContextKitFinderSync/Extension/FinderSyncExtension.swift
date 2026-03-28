import AppKit
import ContextKitCore
import FinderSync
import Foundation

final class FinderSyncExtension: FIFinderSync {
    private let helperClient = ContextKitHelperClient(timeout: 5.0)
    private let selectionContextReader = SelectionContextReader()
    private let menuInvocationCache = MenuInvocationCache()
    private let menuBuilder = MenuBuilder()
    private let dispatcher = ExtensionActionDispatcher()

    override init() {
        super.init()
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleMonitoredRootsDidChange),
            name: ContextKitHelperConstants.monitoredRootsDidChangeNotification,
            object: nil
        )
        syncObservedDirectories()
    }

    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        syncObservedDirectories()
        let controller = FIFinderSyncController.default()
        guard let selection = selectionContextReader.read(from: controller) else {
            return unavailableMenu()
        }

        let request = selectionContextReader.makeRequest(from: selection)
        let nodes = (try? helperClient.menu(for: request)) ?? unavailableNodes()
        menuInvocationCache.update(selection: selection)
        return menuBuilder.build(nodes: nodes, target: self, action: #selector(handleMenuItem(_:)))
    }

    @IBAction nonisolated func handleMenuItem(_ sender: Any?) {
        guard let targetID = Self.actionIdentifier(from: sender),
              let targetType = Self.targetType(from: sender) else {
            NSLog("ContextKitFinderSync missing action metadata for sender: %@", String(describing: sender))
            return
        }

        let snapshot = menuInvocationCache.currentSnapshot()
        Task { @MainActor in
            Self.dispatchMenuAction(
                targetID: targetID,
                targetType: targetType,
                snapshot: snapshot
            )
        }
    }

    @MainActor
    private static func dispatchMenuAction(
        targetID: String,
        targetType: TargetType,
        snapshot: MenuInvocationSnapshot?
    ) {
        let selectionContextReader = SelectionContextReader()
        let dispatcher = ExtensionActionDispatcher()
        let controller = FIFinderSyncController.default()

        guard let selection = selectionContextReader.read(from: controller) ?? snapshot?.selection else {
            NSLog("ContextKitFinderSync could not resolve current selection for target %@", targetID)
            return
        }

        let request = selectionContextReader.makeExecutionRequest(
            targetID: targetID,
            targetType: targetType,
            selection: selection
        )

        do {
            let result = try dispatcher.dispatch(request)
            NSLog(
                "ContextKitFinderSync executed %@ with status %@: %@",
                targetID,
                result.status.rawValue,
                result.message
            )
        } catch {
            NSLog(
                "ContextKitFinderSync failed to execute %@: %@",
                targetID,
                error.localizedDescription
            )
        }
    }

    private func syncObservedDirectories() {
        let paths = (try? helperClient.observedRoots()) ?? []
        FIFinderSyncController.default().directoryURLs = Set(paths.map(URL.init(fileURLWithPath:)))
    }

    @objc private func handleMonitoredRootsDidChange(_ notification: Notification) {
        syncObservedDirectories()
    }

    nonisolated private static func actionIdentifier(from sender: Any?) -> String? {
        guard let item = sender as? NSMenuItem else {
            return nil
        }

        let identifier = item.identifier?.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let identifier, !identifier.isEmpty else {
            return nil
        }
        return identifier
    }

    nonisolated private static func targetType(from sender: Any?) -> TargetType? {
        guard let item = sender as? NSMenuItem,
              let rawValue = item.representedObject as? String else {
            return nil
        }
        return TargetType(rawValue: rawValue)
    }

    private func unavailableMenu() -> NSMenu {
        menuBuilder.build(nodes: unavailableNodes(), target: self, action: #selector(handleMenuItem(_:)))
    }

    private func unavailableNodes() -> [FinderMenuNode] {
        [
            FinderMenuNode(
                id: "finder.helper.unavailable",
                title: "ContextKit unavailable",
                kind: .message,
                enabled: false
            ),
        ]
    }
}
