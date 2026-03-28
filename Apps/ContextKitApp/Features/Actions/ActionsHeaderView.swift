import ContextKitCore
import SwiftUI

struct ActionsHeaderView: View {
    let addGroup: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(
                L10n.string(
                    "app.actions.description",
                    fallback: "Edit the Finder menu tree here. Reorder items, create groups, and change nesting without duplicating action logic."
                )
            )
            .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button(L10n.string("app.actions.addGroup", fallback: "Add Group"), action: addGroup)
            }
        }
    }
}
