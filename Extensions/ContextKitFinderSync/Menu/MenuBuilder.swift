import AppKit
import ContextKitCore
import Foundation

final class MenuInvocationPayload: NSObject {
    let request: ExecutionRequest

    init(request: ExecutionRequest) {
        self.request = request
    }
}

struct MenuBuilder {
    private let sectionProvider = MenuSectionProvider()

    func build(
        descriptors: [MenuDescriptor],
        selection: SelectionContext,
        target: AnyObject,
        action: Selector
    ) -> NSMenu {
        let menu = NSMenu(title: L10n.string("finder.menu.title", fallback: "ContextKit"))
        let matchingDescriptors = descriptors
            .filter(\.isEnabled)
            .filter { $0.contextRules.matches(snapshot: selection.snapshot) }

        guard !matchingDescriptors.isEmpty else {
            let item = NSMenuItem(title: L10n.string("finder.menu.noMatchingActions", fallback: "No matching actions"), action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
            return menu
        }

        for (category, items) in sectionProvider.sections(for: matchingDescriptors) {
            let submenu = NSMenu(title: category.displayName)
            for itemDescriptor in items {
                let item = NSMenuItem(title: itemDescriptor.title, action: action, keyEquivalent: "")
                item.target = target
                item.representedObject = MenuInvocationPayload(
                    request: ExecutionRequest(
                        targetId: itemDescriptor.id,
                        targetType: itemDescriptor.targetType,
                        selectedURLs: selection.selectedURLs,
                        invocationSource: .finder,
                        monitoredRootURL: selection.monitoredRootURL
                    )
                )
                submenu.addItem(item)
            }

            let categoryItem = NSMenuItem(title: category.displayName, action: nil, keyEquivalent: "")
            categoryItem.submenu = submenu
            menu.addItem(categoryItem)
        }

        return menu
    }
}
