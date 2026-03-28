import ContextKitCore
import SwiftUI

struct ActionsDropZoneView: View {
    let viewModel: ActionsViewModel

    var body: some View {
        Color.clear
            .frame(height: 24)
            .overlay(alignment: .center) {
                Text(L10n.string("app.actions.dropToRoot", fallback: "Drop here to move to the top level"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .dropDestination(for: String.self, action: handleDrop)
    }

    private func handleDrop(items: [String], _: CGPoint) -> Bool {
        guard let draggedID = items.first else {
            return false
        }
        return viewModel.handleDropAtRoot(draggedItemID: draggedID)
    }
}
