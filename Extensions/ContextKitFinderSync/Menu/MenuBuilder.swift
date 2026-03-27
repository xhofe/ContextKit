import AppKit
import ContextKitCore
import Foundation

struct MenuBuilder {
    private let sectionProvider = MenuSectionProvider()

    func matchingDescriptors(
        descriptors: [MenuDescriptor],
        selection: SelectionContext
    ) -> [MenuDescriptor] {
        descriptors
            .filter(\.isEnabled)
            .filter { $0.contextRules.matches(snapshot: selection.snapshot) }
    }

    func build(
        matchingDescriptors: [MenuDescriptor],
        target: AnyObject,
        action: Selector
    ) -> NSMenu {
        let menu = NSMenu(title: L10n.string("finder.menu.title", fallback: "ContextKit"))
        menu.autoenablesItems = false
        guard !matchingDescriptors.isEmpty else {
            let item = NSMenuItem(title: L10n.string("finder.menu.noMatchingActions", fallback: "No matching actions"), action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
            return menu
        }

        for (category, items) in sectionProvider.sections(for: matchingDescriptors) {
            let submenu = NSMenu(title: category.displayName)
            submenu.autoenablesItems = false
            for itemDescriptor in items {
                let item = NSMenuItem(title: itemDescriptor.title, action: action, keyEquivalent: "")
                item.isEnabled = true
                item.target = target
                item.identifier = NSUserInterfaceItemIdentifier(itemDescriptor.id)
                item.representedObject = itemDescriptor.id as NSString
                submenu.addItem(item)
            }

            let categoryItem = NSMenuItem(title: category.displayName, action: nil, keyEquivalent: "")
            categoryItem.submenu = submenu
            menu.addItem(categoryItem)
        }

        return menu
    }
}
