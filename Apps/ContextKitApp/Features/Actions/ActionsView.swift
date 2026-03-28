import ContextKitCore
import SwiftUI

struct ActionsView: View {
    let viewModel: ActionsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ActionsHeaderView(addGroup: addGroup)

            List {
                ForEach(viewModel.items) { item in
                    ActionListRowView(item: item, viewModel: viewModel)
                }

                ActionsDropZoneView(viewModel: viewModel)
            }
            .listStyle(.inset)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .padding(24)
        .navigationTitle(L10n.string("app.actions.navigation", fallback: "Actions"))
        .task {
            viewModel.reload()
        }
    }

    private func addGroup() {
        viewModel.addGroup()
    }
}
