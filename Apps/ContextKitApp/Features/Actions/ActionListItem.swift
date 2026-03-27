import ContextKitCore
import Foundation

struct ActionListItem: Identifiable {
    var id: String { manifest.id }
    let manifest: ActionManifest
    let isEnabled: Bool
}
