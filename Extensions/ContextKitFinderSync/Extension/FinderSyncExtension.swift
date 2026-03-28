import AppKit
import ContextKitCore
import FinderSync
import Foundation

final class FinderSyncExtension: FIFinderSync {
    private let settingsStore = SharedSettingsStore()
    private let cache = MenuDescriptorCache()
    private let selectionContextReader = SelectionContextReader()
    private let menuInvocationCache = MenuInvocationCache()
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

        let matchingDescriptors = menuBuilder.matchingDescriptors(
            descriptors: descriptors,
            selection: selection
        )
        menuInvocationCache.update(selection: selection, descriptors: matchingDescriptors)

        return menuBuilder.build(
            matchingDescriptors: matchingDescriptors,
            target: self,
            action: #selector(handleMenuItem(_:))
        )
    }

    @IBAction nonisolated func handleMenuItem(_ sender: Any?) {
        let targetId = Self.actionIdentifier(from: sender)
        let fallbackTitle = Self.menuItemTitle(from: sender)

        guard targetId != nil || fallbackTitle != nil else {
            NSLog(
                "ContextKitFinderSync menu click missing action identifier and title. senderType=%@ sender=%@",
                Self.senderTypeDescription(sender),
                Self.senderDebugDescription(sender)
            )
            return
        }

        NSLog(
            "ContextKitFinderSync handling menu click: id=%@ title=%@",
            targetId ?? "<nil>",
            fallbackTitle ?? "<nil>"
        )
        let snapshot = menuInvocationCache.currentSnapshot()
        Task { @MainActor in
            Self.dispatchMenuAction(
                targetId: targetId,
                fallbackTitle: fallbackTitle,
                snapshot: snapshot
            )
        }
    }

    @MainActor
    private static func dispatchMenuAction(
        targetId: String?,
        fallbackTitle: String?,
        snapshot: MenuInvocationSnapshot?
    ) {
        let selectionContextReader = SelectionContextReader()
        let cache = MenuDescriptorCache()
        let dispatcher = ExtensionActionDispatcher()
        let controller = FIFinderSyncController.default()
        guard let selection = selectionContextReader.read(from: controller) ?? snapshot?.selection else {
            NSLog(
                "ContextKitFinderSync could not resolve current selection for target: %@ title: %@",
                targetId ?? "<nil>",
                fallbackTitle ?? "<nil>"
            )
            return
        }

        guard let descriptor = descriptor(
            for: targetId,
            fallbackTitle: fallbackTitle,
            selection: selection,
            cachedDescriptors: snapshot?.descriptors,
            cache: cache
        ) else {
            NSLog(
                "ContextKitFinderSync missing descriptor for target: %@ title: %@",
                targetId ?? "<nil>",
                fallbackTitle ?? "<nil>"
            )
            return
        }

        let request = ExecutionRequest(
            targetId: descriptor.id,
            targetType: descriptor.targetType ?? .action,
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
        if let item = sender as? NSMenuItem {
            if let identifier = normalizedIdentifier(item.identifier?.rawValue ?? "") {
                return identifier
            }

            if let representedIdentifier = representedIdentifier(from: item.representedObject) {
                return representedIdentifier
            }
        }

        if let dictionary = sender as? NSDictionary {
            for key in ["identifier", "id", "representedObject"] {
                if let identifier = representedIdentifier(from: dictionary[key]) {
                    return identifier
                }
            }
        }

        guard let object = sender as AnyObject?,
              let identifier = identifierFromKeyValueCoding(object) ?? representedObjectFromKeyValueCoding(object) else {
            return nil
        }

        return identifier
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
            return normalizedIdentifier(identifier.rawValue)
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
            return normalizedIdentifier(identifier)
        }

        if let identifier = value as? NSString {
            return normalizedIdentifier(identifier as String)
        }

        return nil
    }

    private static func descriptor(
        for targetId: String?,
        fallbackTitle: String?,
        selection: SelectionContext,
        cachedDescriptors: [MenuDescriptor]?,
        cache: MenuDescriptorCache
    ) -> MenuDescriptor? {
        let matchingDescriptors = cachedDescriptors ?? {
            guard let descriptors = try? cache.load() else {
                return []
            }

            return descriptors
                .filter(\.isEnabled)
                .filter { $0.contextRules.matches(snapshot: selection.snapshot) }
        }()

        if let targetId,
           let matchedDescriptor = matchingDescriptors.first(where: { $0.id == targetId }) {
            return matchedDescriptor
        }

        guard let fallbackTitle else {
            return nil
        }

        return matchingDescriptors.first { $0.title == fallbackTitle }
    }

    private static func normalizedIdentifier(_ rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        if trimmed == "handleMenuItem:" || trimmed.hasSuffix(":") {
            return nil
        }

        return trimmed
    }

    private static func senderTypeDescription(_ sender: Any?) -> String {
        guard let sender else {
            return "nil"
        }

        if let object = sender as AnyObject? {
            return NSStringFromClass(type(of: object))
        }

        return String(describing: type(of: sender))
    }

    private static func senderDebugDescription(_ sender: Any?) -> String {
        guard let sender else {
            return "nil"
        }

        if let object = sender as AnyObject? {
            return String(describing: object)
        }

        return String(describing: sender)
    }
}
