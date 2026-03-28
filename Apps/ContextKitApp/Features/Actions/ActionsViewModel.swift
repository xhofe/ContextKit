import ContextKitCore
import Foundation

@MainActor
final class ActionsViewModel: ObservableObject {
    @Published var items: [ActionListItem] = []
    @Published var errorMessage: String?

    private let services: ContextKitAppServices
    private var menuLayout: [MenuLayoutItem] = []
    private var actionManifestsByID: [String: ActionManifest] = [:]
    private var workflowsByID: [String: WorkflowManifest] = [:]
    private var settings = AppSettings()

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            let catalog = try services.loadCatalog()
            settings = try services.loadSettings()
            menuLayout = try services.loadResolvedMenuLayout()
            actionManifestsByID = Dictionary(uniqueKeysWithValues: catalog.actions.map { ($0.id, $0) })
            workflowsByID = Dictionary(uniqueKeysWithValues: catalog.workflows.map { ($0.id, $0) })
            rebuildItems()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setEnabled(_ enabled: Bool, for item: ActionListItem) {
        guard item.isAction else {
            return
        }

        do {
            try services.toggleAction(item.id, enabled: enabled)
            settings = try services.loadSettings()
            rebuildItems()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addGroup(parentID: String? = nil) {
        menuLayout = MenuLayoutEditor.addGroup(
            title: L10n.string("app.actions.newGroup", fallback: "New Group"),
            parentID: parentID,
            to: menuLayout
        )
        saveMenuLayout()
    }

    func moveUp(_ item: ActionListItem) {
        menuLayout = MenuLayoutEditor.moveUp(id: item.id, in: menuLayout)
        saveMenuLayout()
    }

    func moveDown(_ item: ActionListItem) {
        menuLayout = MenuLayoutEditor.moveDown(id: item.id, in: menuLayout)
        saveMenuLayout()
    }

    func indent(_ item: ActionListItem) {
        menuLayout = MenuLayoutEditor.indent(id: item.id, in: menuLayout)
        saveMenuLayout()
    }

    func outdent(_ item: ActionListItem) {
        menuLayout = MenuLayoutEditor.outdent(id: item.id, in: menuLayout)
        saveMenuLayout()
    }

    func removeGroup(_ item: ActionListItem) {
        guard item.isGroup else {
            return
        }

        menuLayout = MenuLayoutEditor.removeGroup(id: item.id, from: menuLayout)
        saveMenuLayout()
    }

    func updateGroupTitle(_ title: String, for item: ActionListItem) {
        guard item.isGroup else {
            return
        }

        menuLayout = MenuLayoutEditor.renameGroup(id: item.id, title: title, in: menuLayout)
        saveMenuLayout()
    }

    func canMoveUp(_ item: ActionListItem) -> Bool {
        MenuLayoutEditor.canMoveUp(id: item.id, in: menuLayout)
    }

    func canMoveDown(_ item: ActionListItem) -> Bool {
        MenuLayoutEditor.canMoveDown(id: item.id, in: menuLayout)
    }

    func canIndent(_ item: ActionListItem) -> Bool {
        MenuLayoutEditor.canIndent(id: item.id, in: menuLayout)
    }

    func canOutdent(_ item: ActionListItem) -> Bool {
        MenuLayoutEditor.canOutdent(id: item.id, in: menuLayout)
    }

    @discardableResult
    func handleDrop(draggedItemID: String, before targetItem: ActionListItem) -> Bool {
        guard draggedItemID != targetItem.id else {
            return false
        }

        menuLayout = MenuLayoutEditor.moveBefore(
            draggedID: draggedItemID,
            targetID: targetItem.id,
            in: menuLayout
        )
        saveMenuLayout()
        return true
    }

    @discardableResult
    func handleDropIntoGroup(draggedItemID: String, groupItem: ActionListItem) -> Bool {
        guard groupItem.isGroup, draggedItemID != groupItem.id else {
            return false
        }

        menuLayout = MenuLayoutEditor.moveIntoGroup(
            draggedID: draggedItemID,
            groupID: groupItem.id,
            in: menuLayout
        )
        saveMenuLayout()
        return true
    }

    @discardableResult
    func handleDropAtRoot(draggedItemID: String) -> Bool {
        menuLayout = MenuLayoutEditor.moveToRootEnd(draggedID: draggedItemID, in: menuLayout)
        saveMenuLayout()
        return true
    }

    private func rebuildItems() {
        items = MenuLayoutEditor.flatten(
            items: menuLayout,
            actionsByID: actionManifestsByID,
            workflowsByID: workflowsByID,
            settings: settings
        )
    }

    private func saveMenuLayout() {
        do {
            try services.saveMenuLayout(menuLayout)
            rebuildItems()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
