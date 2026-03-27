import ContextKitCore
import Foundation

@MainActor
final class ActionsViewModel: ObservableObject {
    @Published var items: [ActionListItem] = []
    @Published var errorMessage: String?

    private let services: ContextKitAppServices

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            let catalog = try services.loadCatalog()
            let settings = try services.loadSettings()
            items = catalog.actions.map { manifest in
                ActionListItem(manifest: manifest, isEnabled: settings.isActionEnabled(manifest.id))
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setEnabled(_ enabled: Bool, for item: ActionListItem) {
        do {
            try services.toggleAction(item.id, enabled: enabled)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func move(from offsets: IndexSet, to destination: Int) {
        var updated = items
        updated.move(fromOffsets: offsets, toOffset: destination)
        do {
            try services.updateOrderedActionIDs(updated.map(\.id))
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func moveUp(_ item: ActionListItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }), index > 0 else {
            return
        }
        updateOrder(swapping: index, with: index - 1)
    }

    func moveDown(_ item: ActionListItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }), index < items.count - 1 else {
            return
        }
        updateOrder(swapping: index, with: index + 1)
    }

    private func updateOrder(swapping firstIndex: Int, with secondIndex: Int) {
        var updated = items
        updated.swapAt(firstIndex, secondIndex)
        do {
            try services.updateOrderedActionIDs(updated.map(\.id))
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
