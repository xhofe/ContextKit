import ContextKitCore
import SwiftUI

struct ActionsDropIntoGroupIndicator: View {
    let item: ActionListItem
    let viewModel: ActionsViewModel

    var body: some View {
        Image(systemName: "tray.and.arrow.down")
            .foregroundStyle(.secondary)
            .help(L10n.string("app.actions.dropIntoGroup", fallback: "Drop here to move the dragged item into this group."))
            .dropDestination(for: String.self, action: handleDrop)
    }

    private func handleDrop(items: [String], _: CGPoint) -> Bool {
        guard let draggedID = items.first else {
            return false
        }
        return viewModel.handleDropIntoGroup(draggedItemID: draggedID, groupItem: item)
    }
}
