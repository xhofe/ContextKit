import ContextKitCore
import Foundation

enum MenuLayoutEditor {
    static func flatten(
        items: [MenuLayoutItem],
        actionsByID: [String: ActionManifest],
        workflowsByID: [String: WorkflowManifest],
        settings: AppSettings
    ) -> [ActionListItem] {
        flatten(
            items: items,
            depth: 0,
            actionsByID: actionsByID,
            workflowsByID: workflowsByID,
            settings: settings
        )
    }

    static func addGroup(
        title: String,
        parentID: String?,
        to items: [MenuLayoutItem]
    ) -> [MenuLayoutItem] {
        let group = MenuLayoutItem.group(title: title)
        guard let parentID else {
            return items + [group]
        }

        return append(group, toGroupID: parentID, in: items)
    }

    static func renameGroup(
        id: String,
        title: String,
        in items: [MenuLayoutItem]
    ) -> [MenuLayoutItem] {
        items.map { item in
            guard item.id == id, item.kind == .group else {
                var updated = item
                updated.children = renameGroup(id: id, title: title, in: item.children)
                return updated
            }

            var updated = item
            updated.title = title
            return updated
        }
    }

    static func removeGroup(id: String, from items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        guard let path = indexPath(for: id, in: items) else {
            return items
        }
        return hoistGroup(at: path, in: items)
    }

    static func moveUp(id: String, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        move(id: id, delta: -1, in: items)
    }

    static func moveDown(id: String, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        move(id: id, delta: 1, in: items)
    }

    static func moveBefore(
        draggedID: String,
        targetID: String,
        in items: [MenuLayoutItem]
    ) -> [MenuLayoutItem] {
        guard draggedID != targetID,
              let draggedPath = indexPath(for: draggedID, in: items),
              let targetPath = indexPath(for: targetID, in: items),
              !targetPath.starts(with: draggedPath) else {
            return items
        }

        let (draggedItem, withoutDraggedItem) = remove(at: draggedPath, from: items)
        guard let updatedTargetPath = indexPath(for: targetID, in: withoutDraggedItem) else {
            return items
        }

        return insert(draggedItem, at: updatedTargetPath, in: withoutDraggedItem)
    }

    static func moveIntoGroup(
        draggedID: String,
        groupID: String,
        in items: [MenuLayoutItem]
    ) -> [MenuLayoutItem] {
        guard draggedID != groupID,
              let draggedPath = indexPath(for: draggedID, in: items),
              let groupPath = indexPath(for: groupID, in: items),
              item(at: groupPath, in: items).kind == .group,
              !groupPath.starts(with: draggedPath) else {
            return items
        }

        let (draggedItem, withoutDraggedItem) = remove(at: draggedPath, from: items)
        guard let updatedGroupPath = indexPath(for: groupID, in: withoutDraggedItem) else {
            return items
        }

        return append(draggedItem, toPath: updatedGroupPath, in: withoutDraggedItem)
    }

    static func moveToRootEnd(draggedID: String, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        guard let draggedPath = indexPath(for: draggedID, in: items) else {
            return items
        }

        let (draggedItem, withoutDraggedItem) = remove(at: draggedPath, from: items)
        return withoutDraggedItem + [draggedItem]
    }

    static func indent(id: String, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        guard let path = indexPath(for: id, in: items),
              let currentIndex = path.last,
              currentIndex > 0 else {
            return items
        }

        let siblingPath = Array(path.dropLast()) + [currentIndex - 1]
        guard item(at: siblingPath, in: items).kind == .group else {
            return items
        }

        let (movedItem, withoutItem) = remove(at: path, from: items)
        return append(movedItem, toPath: siblingPath, in: withoutItem)
    }

    static func outdent(id: String, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        guard let path = indexPath(for: id, in: items), path.count > 1 else {
            return items
        }

        let parentPath = Array(path.dropLast())
        let grandParentPath = Array(path.dropLast(2))
        guard let parentIndex = parentPath.last else {
            return items
        }

        let (movedItem, withoutItem) = remove(at: path, from: items)
        let insertionPath = grandParentPath + [parentIndex + 1]
        return insert(movedItem, at: insertionPath, in: withoutItem)
    }

    static func canMoveUp(id: String, in items: [MenuLayoutItem]) -> Bool {
        guard let path = indexPath(for: id, in: items), let index = path.last else {
            return false
        }
        return index > 0
    }

    static func canMoveDown(id: String, in items: [MenuLayoutItem]) -> Bool {
        guard let path = indexPath(for: id, in: items), let index = path.last else {
            return false
        }
        let siblings = children(at: Array(path.dropLast()), in: items)
        return index < siblings.count - 1
    }

    static func canIndent(id: String, in items: [MenuLayoutItem]) -> Bool {
        guard let path = indexPath(for: id, in: items), let index = path.last, index > 0 else {
            return false
        }
        let siblingPath = Array(path.dropLast()) + [index - 1]
        return item(at: siblingPath, in: items).kind == .group
    }

    static func canOutdent(id: String, in items: [MenuLayoutItem]) -> Bool {
        guard let path = indexPath(for: id, in: items) else {
            return false
        }
        return path.count > 1
    }

    private static func flatten(
        items: [MenuLayoutItem],
        depth: Int,
        actionsByID: [String: ActionManifest],
        workflowsByID: [String: WorkflowManifest],
        settings: AppSettings
    ) -> [ActionListItem] {
        items.flatMap { item in
            let currentItem: ActionListItem?
            switch item.kind {
            case .group:
                currentItem = ActionListItem(
                    node: item,
                    depth: depth,
                    title: item.title ?? "",
                    subtitle: L10n.string("app.actions.groupLabel", fallback: "Menu Group"),
                    isEnabled: true
                )
            case .action:
                if let manifest = actionsByID[item.id] {
                    currentItem = ActionListItem(
                        node: item,
                        depth: depth,
                        title: manifest.name,
                        subtitle: "\(manifest.category.displayName) · \(manifest.kind.displayName)",
                        isEnabled: settings.isActionEnabled(manifest.id)
                    )
                } else {
                    currentItem = nil
                }
            case .workflow:
                if let workflow = workflowsByID[item.id] {
                    currentItem = ActionListItem(
                        node: item,
                        depth: depth,
                        title: workflow.name,
                        subtitle: L10n.string("app.actions.workflowLabel", fallback: "Workflow"),
                        isEnabled: true
                    )
                } else {
                    currentItem = nil
                }
            }

            return [currentItem].compactMap { $0 } + flatten(
                items: item.children,
                depth: depth + 1,
                actionsByID: actionsByID,
                workflowsByID: workflowsByID,
                settings: settings
            )
        }
    }

    private static func move(id: String, delta: Int, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        guard let path = indexPath(for: id, in: items), let currentIndex = path.last else {
            return items
        }

        let siblings = children(at: Array(path.dropLast()), in: items)
        let destinationIndex = currentIndex + delta
        guard siblings.indices.contains(destinationIndex) else {
            return items
        }

        let (movedItem, withoutItem) = remove(at: path, from: items)
        let insertionIndex = delta > 0 ? destinationIndex : destinationIndex
        return insert(movedItem, at: Array(path.dropLast()) + [insertionIndex], in: withoutItem)
    }

    private static func append(_ item: MenuLayoutItem, toGroupID parentID: String, in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        items.map { current in
            guard current.id != parentID || current.kind != .group else {
                var updated = current
                updated.children.append(item)
                return updated
            }

            var updated = current
            updated.children = append(item, toGroupID: parentID, in: current.children)
            return updated
        }
    }

    private static func indexPath(for id: String, in items: [MenuLayoutItem]) -> [Int]? {
        for (index, item) in items.enumerated() {
            if item.id == id {
                return [index]
            }

            if let childPath = indexPath(for: id, in: item.children) {
                return [index] + childPath
            }
        }

        return nil
    }

    private static func item(at path: [Int], in items: [MenuLayoutItem]) -> MenuLayoutItem {
        var currentItems = items
        var currentItem: MenuLayoutItem?

        for index in path {
            currentItem = currentItems[index]
            currentItems = currentItem?.children ?? []
        }

        return currentItem ?? .group(title: "")
    }

    private static func children(at parentPath: [Int], in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        guard !parentPath.isEmpty else {
            return items
        }

        return item(at: parentPath, in: items).children
    }

    private static func remove(at path: [Int], from items: [MenuLayoutItem]) -> (MenuLayoutItem, [MenuLayoutItem]) {
        if path.count == 1 {
            var updated = items
            let removed = updated.remove(at: path[0])
            return (removed, updated)
        }

        var updated = items
        let index = path[0]
        let result = remove(at: Array(path.dropFirst()), from: updated[index].children)
        updated[index].children = result.1
        return (result.0, updated)
    }

    private static func insert(_ item: MenuLayoutItem, at path: [Int], in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        if path.count == 1 {
            var updated = items
            let index = min(max(path[0], 0), updated.count)
            updated.insert(item, at: index)
            return updated
        }

        var updated = items
        let index = path[0]
        updated[index].children = insert(item, at: Array(path.dropFirst()), in: updated[index].children)
        return updated
    }

    private static func append(_ item: MenuLayoutItem, toPath path: [Int], in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        if path.count == 1 {
            var updated = items
            updated[path[0]].children.append(item)
            return updated
        }

        var updated = items
        let index = path[0]
        updated[index].children = append(item, toPath: Array(path.dropFirst()), in: updated[index].children)
        return updated
    }

    private static func hoistGroup(at path: [Int], in items: [MenuLayoutItem]) -> [MenuLayoutItem] {
        if path.count == 1 {
            var updated = items
            let group = updated.remove(at: path[0])
            updated.insert(contentsOf: group.children, at: path[0])
            return updated
        }

        var updated = items
        let index = path[0]
        updated[index].children = hoistGroup(at: Array(path.dropFirst()), in: updated[index].children)
        return updated
    }
}
