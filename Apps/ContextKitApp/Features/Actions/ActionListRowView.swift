import ContextKitCore
import SwiftUI

struct ActionListRowView: View {
    let item: ActionListItem
    let viewModel: ActionsViewModel
    @State private var groupTitle: String
    @State private var isEnabled: Bool

    init(item: ActionListItem, viewModel: ActionsViewModel) {
        self.item = item
        self.viewModel = viewModel
        _groupTitle = State(initialValue: item.title)
        _isEnabled = State(initialValue: item.isEnabled)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if item.isGroup {
                    TextField(
                        L10n.string("app.actions.groupName", fallback: "Group Name"),
                        text: $groupTitle,
                        prompt: Text(L10n.string("app.actions.groupName", fallback: "Group Name"))
                    )
                    .onSubmit(commitGroupTitle)
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
                ActionsDropIntoGroupIndicator(item: item, viewModel: viewModel)

                Button(action: addChildGroup) {
                    Label("Add Child Group", systemImage: "folder.badge.plus")
                }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)

                Button(role: .destructive, action: removeGroup) {
                    Label("Delete Group", systemImage: "trash")
                }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
            }

            Button(action: moveUp) {
                Label("Move Up", systemImage: "chevron.up")
            }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .disabled(!viewModel.canMoveUp(item))

            Button(action: moveDown) {
                Label("Move Down", systemImage: "chevron.down")
            }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .disabled(!viewModel.canMoveDown(item))

            Button(action: indent) {
                Label("Indent", systemImage: "arrow.right.to.line")
            }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .disabled(!viewModel.canIndent(item))

            Button(action: outdent) {
                Label("Outdent", systemImage: "arrow.left.to.line")
            }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .disabled(!viewModel.canOutdent(item))

            if item.isAction {
                Toggle("Enabled", isOn: $isEnabled)
                    .labelsHidden()
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .draggable(item.id)
        .dropDestination(for: String.self, action: handleDrop)
        .onChange(of: item.title) { _, newValue in
            groupTitle = newValue
        }
        .onChange(of: item.isEnabled) { _, newValue in
            isEnabled = newValue
        }
        .onChange(of: isEnabled) { _, newValue in
            guard item.isAction else { return }
            viewModel.setEnabled(newValue, for: item)
        }
    }

    private func addChildGroup() {
        viewModel.addGroup(parentID: item.id)
    }

    private func commitGroupTitle() {
        guard item.isGroup else {
            return
        }
        viewModel.updateGroupTitle(groupTitle, for: item)
    }

    private func removeGroup() {
        viewModel.removeGroup(item)
    }

    private func moveUp() {
        viewModel.moveUp(item)
    }

    private func moveDown() {
        viewModel.moveDown(item)
    }

    private func indent() {
        viewModel.indent(item)
    }

    private func outdent() {
        viewModel.outdent(item)
    }

    private func handleDrop(items: [String], _: CGPoint) -> Bool {
        guard let draggedID = items.first else {
            return false
        }
        return viewModel.handleDrop(draggedItemID: draggedID, before: item)
    }
}
