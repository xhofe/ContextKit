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
        menuInvocationCache.update(selection: selection, nodes: nodes)
        return menuBuilder.build(nodes: nodes, target: self, action: #selector(handleMenuItem(_:)))
    }

    @IBAction nonisolated func handleMenuItem(_ sender: Any?) {
        let targetID = Self.actionIdentifier(from: sender)
        let fallbackTitle = Self.menuItemTitle(from: sender)
        let targetType = Self.targetType(from: sender)
        let snapshot = menuInvocationCache.currentSnapshot()
        Task { @MainActor in
            Self.dispatchMenuAction(
                targetID: targetID,
                fallbackTitle: fallbackTitle,
                targetType: targetType,
                snapshot: snapshot
            )
        }
    }

    @MainActor
    private static func dispatchMenuAction(
        targetID: String?,
        fallbackTitle: String?,
        targetType: TargetType?,
        snapshot: MenuInvocationSnapshot?
    ) {
        let selectionContextReader = SelectionContextReader()
        let dispatcher = ExtensionActionDispatcher()
        let controller = FIFinderSyncController.default()

        guard let selection = selectionContextReader.read(from: controller) ?? snapshot?.selection else {
            NSLog("ContextKitFinderSync could not resolve current selection for target \(targetID ?? "<nil>")")
            return
        }

        guard let resolvedNode = resolveNode(
            targetID: targetID,
            fallbackTitle: fallbackTitle,
            snapshot: snapshot
        ) else {
            NSLog(
                "ContextKitFinderSync missing action metadata for sender target=%@ title=%@",
                targetID ?? "<nil>",
                fallbackTitle ?? "<nil>"
            )
            return
        }

        let request = selectionContextReader.makeExecutionRequest(
            targetID: resolvedNode.id,
            targetType: resolvedNode.targetType ?? targetType ?? .action,
            selection: selection
        )

        do {
            let result = try dispatcher.dispatch(request)
            NSLog(
                "ContextKitFinderSync executed %@ with status %@: %@",
                resolvedNode.id,
                result.status.rawValue,
                result.message
            )
        } catch {
            NSLog(
                "ContextKitFinderSync failed to execute %@: %@",
                resolvedNode.id,
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
        if let item = sender as? NSMenuItem {
            let identifier = item.identifier?.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let identifier, !identifier.isEmpty else {
                return nil
            }
            return identifier
        }

        if let dictionary = sender as? NSDictionary {
            for key in ["identifier", "id", "representedObject"] {
                if let identifier = representedIdentifier(from: dictionary[key]) {
                    return identifier
                }
            }
        }

        guard let object = sender as AnyObject? else {
            return nil
        }

        return identifierFromKeyValueCoding(object) ?? representedObjectFromKeyValueCoding(object)
    }

    nonisolated private static func targetType(from sender: Any?) -> TargetType? {
        if let item = sender as? NSMenuItem,
           let rawValue = item.representedObject as? String {
            return TargetType(rawValue: rawValue)
        }

        if let dictionary = sender as? NSDictionary,
           let rawValue = dictionary["targetType"] as? String {
            return TargetType(rawValue: rawValue)
        }

        guard let object = sender as AnyObject?,
              let rawValue = object.value(forKey: "representedObject") as? String else {
            return nil
        }

        return TargetType(rawValue: rawValue)
    }

    nonisolated private static func menuItemTitle(from sender: Any?) -> String? {
        if let item = sender as? NSMenuItem {
            let title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
            return title.isEmpty ? nil : title
        }

        if let dictionary = sender as? NSDictionary {
            for key in ["title", "name"] {
                if let value = dictionary[key] as? String {
                    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        return trimmed
                    }
                }
            }
        }

        guard let object = sender as AnyObject?,
              let value = object.value(forKey: "title") as? String else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func identifierFromKeyValueCoding(_ object: AnyObject) -> String? {
        guard let value = object.value(forKey: "identifier") else {
            return nil
        }

        if let identifier = value as? NSUserInterfaceItemIdentifier {
            let trimmed = identifier.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        return representedIdentifier(from: value)
    }

    private static func representedObjectFromKeyValueCoding(_ object: AnyObject) -> String? {
        guard let value = object.value(forKey: "representedObject") else {
            return nil
        }

        return representedIdentifier(from: value)
    }

    private static func representedIdentifier(from value: Any?) -> String? {
        if let identifier = value as? String {
            let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        if let identifier = value as? NSString {
            let trimmed = (identifier as String).trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        return nil
    }

    private static func resolveNode(
        targetID: String?,
        fallbackTitle: String?,
        snapshot: MenuInvocationSnapshot?
    ) -> FinderMenuNode? {
        guard let snapshot else {
            return nil
        }

        let flattenedNodes = flatten(nodes: snapshot.nodes)
        if let targetID,
           let node = flattenedNodes.first(where: { $0.id == targetID }) {
            return node
        }

        guard let fallbackTitle else {
            return nil
        }

        return flattenedNodes.first(where: { $0.title == fallbackTitle })
    }

    private static func flatten(nodes: [FinderMenuNode]) -> [FinderMenuNode] {
        nodes.flatMap { node in
            [node] + flatten(nodes: node.children)
        }
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
