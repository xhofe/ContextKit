import AppKit
import ContextKitCore
import Foundation

struct MenuBuilder {
    func matchingDescriptors(
        descriptors: [MenuDescriptor],
        selection: SelectionContext
    ) -> [MenuDescriptor] {
        let visibleLeaves = descriptors.filter { descriptor in
            descriptor.kind != .group &&
            descriptor.isEnabled &&
            descriptor.contextRules.matches(snapshot: selection.snapshot)
        }

        let descriptorsByID = Dictionary(uniqueKeysWithValues: descriptors.map { ($0.id, $0) })
        var visibleIDs = Set(visibleLeaves.map(\.id))

        for leaf in visibleLeaves {
            var currentParentID = leaf.parentID
            while let parentID = currentParentID, let parent = descriptorsByID[parentID] {
                visibleIDs.insert(parent.id)
                currentParentID = parent.parentID
            }
        }

        return descriptors.filter { visibleIDs.contains($0.id) }
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

        for item in makeMenuItems(
            parentID: nil,
            descriptors: matchingDescriptors,
            target: target,
            action: action
        ) {
            menu.addItem(item)
        }

        return menu
    }

    private func makeMenuItems(
        parentID: String?,
        descriptors: [MenuDescriptor],
        target: AnyObject,
        action: Selector
    ) -> [NSMenuItem] {
        let childDescriptors = descriptors
            .filter { $0.parentID == parentID }
            .sorted(by: { $0.sortOrder < $1.sortOrder })

        return childDescriptors.compactMap { descriptor in
            switch descriptor.kind {
            case .group:
                let children = makeMenuItems(
                    parentID: descriptor.id,
                    descriptors: descriptors,
                    target: target,
                    action: action
                )
                guard !children.isEmpty else {
                    return nil
                }

                let submenu = NSMenu(title: descriptor.title)
                submenu.autoenablesItems = false
                children.forEach { submenu.addItem($0) }

                let categoryItem = NSMenuItem(title: descriptor.title, action: nil, keyEquivalent: "")
                categoryItem.submenu = submenu
                return categoryItem
            case .action, .workflow:
                let item = NSMenuItem(title: descriptor.title, action: action, keyEquivalent: "")
                item.isEnabled = true
                item.target = target
                item.identifier = NSUserInterfaceItemIdentifier(descriptor.id)
                item.representedObject = descriptor.id as NSString
                return item
            }
        }
    }
}
