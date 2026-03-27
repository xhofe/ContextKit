import ContextKitCore
import SwiftUI

struct ActionsView: View {
    @ObservedObject var viewModel: ActionsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(
                L10n.string(
                    "app.actions.description",
                    fallback: "Finder menus, app invocations, and CLI all reuse this ordered action catalog."
                )
            )
                .foregroundStyle(.secondary)

            List {
                ForEach(viewModel.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.manifest.name)
                            Text("\(item.manifest.category.displayName) · \(item.manifest.kind.displayName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            viewModel.moveUp(item)
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .buttonStyle(.borderless)

                        Button {
                            viewModel.moveDown(item)
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .buttonStyle(.borderless)

                        Toggle("", isOn: Binding(
                            get: { item.isEnabled },
                            set: { viewModel.setEnabled($0, for: item) }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
                .onMove(perform: viewModel.move)
            }
            .listStyle(.inset)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .padding(24)
        .navigationTitle(L10n.string("app.actions.navigation", fallback: "Actions"))
        .onAppear(perform: viewModel.reload)
    }
}
