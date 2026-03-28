import ContextKitCore
import SwiftUI

struct ActionsView: View {
    @ObservedObject var viewModel: ActionsViewModel

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
                Button(L10n.string("app.actions.addGroup", fallback: "Add Group")) {
                    viewModel.addGroup()
                }
            }

            List {
                ForEach(viewModel.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if item.isGroup {
                                TextField(
                                    L10n.string("app.actions.groupName", fallback: "Group Name"),
                                    text: Binding(
                                        get: { item.title },
                                        set: { viewModel.updateGroupTitle($0, for: item) }
                                    )
                                )
                            } else {
                                Text(item.title)
                            }

                            if let subtitle = item.subtitle {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.leading, CGFloat(item.depth) * 18)

                        Spacer()

                        if item.isGroup {
                            Image(systemName: "tray.and.arrow.down")
                                .foregroundStyle(.secondary)
                                .help(L10n.string("app.actions.dropIntoGroup", fallback: "Drop here to move the dragged item into this group."))
                                .dropDestination(for: String.self) { items, _ in
                                    guard let draggedID = items.first else {
                                        return false
                                    }
                                    return viewModel.handleDropIntoGroup(draggedItemID: draggedID, groupItem: item)
                                }

                            Button {
                                viewModel.addGroup(parentID: item.id)
                            } label: {
                                Image(systemName: "folder.badge.plus")
                            }
                            .buttonStyle(.borderless)

                            Button {
                                viewModel.removeGroup(item)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }

                        Button {
                            viewModel.moveUp(item)
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .buttonStyle(.borderless)
                        .disabled(!viewModel.canMoveUp(item))

                        Button {
                            viewModel.moveDown(item)
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .buttonStyle(.borderless)
                        .disabled(!viewModel.canMoveDown(item))

                        Button {
                            viewModel.indent(item)
                        } label: {
                            Image(systemName: "arrow.right.to.line")
                        }
                        .buttonStyle(.borderless)
                        .disabled(!viewModel.canIndent(item))

                        Button {
                            viewModel.outdent(item)
                        } label: {
                            Image(systemName: "arrow.left.to.line")
                        }
                        .buttonStyle(.borderless)
                        .disabled(!viewModel.canOutdent(item))

                        if item.isAction {
                            Toggle("", isOn: Binding(
                                get: { item.isEnabled },
                                set: { viewModel.setEnabled($0, for: item) }
                            ))
                            .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .draggable(item.id)
                    .dropDestination(for: String.self) { items, _ in
                        guard let draggedID = items.first else {
                            return false
                        }
                        return viewModel.handleDrop(draggedItemID: draggedID, before: item)
                    }
                }

                Color.clear
                    .frame(height: 24)
                    .overlay(
                        Text(L10n.string("app.actions.dropToRoot", fallback: "Drop here to move to the top level"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    )
                    .dropDestination(for: String.self) { items, _ in
                        guard let draggedID = items.first else {
                            return false
                        }
                        return viewModel.handleDropAtRoot(draggedItemID: draggedID)
                    }
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
