import AppKit
import ContextKitCore
import Foundation

struct MenuBuilder {
    func build(
        nodes: [FinderMenuNode],
        target: AnyObject,
        action: Selector
    ) -> NSMenu {
        let menu = NSMenu(title: L10n.string("finder.menu.title", fallback: "ContextKit"))
        menu.autoenablesItems = false
        guard !nodes.isEmpty else {
            let item = NSMenuItem(title: L10n.string("finder.menu.noMatchingActions", fallback: "No matching actions"), action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
            return menu
        }

        for item in makeMenuItems(nodes: nodes, target: target, action: action) {
            menu.addItem(item)
        }

        return menu
    }

    private func makeMenuItems(
        nodes: [FinderMenuNode],
        target: AnyObject,
        action: Selector
    ) -> [NSMenuItem] {
        nodes.compactMap { node in
            switch node.kind {
            case .group:
                let submenu = NSMenu(title: node.title)
                submenu.autoenablesItems = false
                let children = makeMenuItems(nodes: node.children, target: target, action: action)
                children.forEach { submenu.addItem($0) }

                let categoryItem = NSMenuItem(title: node.title, action: nil, keyEquivalent: "")
                categoryItem.submenu = submenu
                return categoryItem
            case .action, .workflow:
                let item = NSMenuItem(title: node.title, action: action, keyEquivalent: "")
                item.isEnabled = node.enabled
                item.target = target
                item.identifier = NSUserInterfaceItemIdentifier(node.id)
                item.representedObject = node.targetType?.rawValue as NSString?
                return item
            case .message:
                let item = NSMenuItem(title: node.title, action: nil, keyEquivalent: "")
                item.isEnabled = false
                return item
            }
        }
    }
}
