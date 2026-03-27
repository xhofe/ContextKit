import ContextKitCore
import SwiftUI

struct WorkflowEditorView: View {
    @ObservedObject var viewModel: WorkflowsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            TextField(L10n.string("app.workflows.editor.namePlaceholder", fallback: "Workflow name"), text: $viewModel.draft.name)
                .textFieldStyle(.roundedBorder)

            ForEach($viewModel.draft.steps) { $step in
                HStack {
                    Picker(L10n.string("app.workflows.editor.action", fallback: "Action"), selection: $step.actionID) {
                        ForEach(viewModel.availableActions, id: \.id) { action in
                            Text(action.name).tag(action.id)
                        }
                    }

                    Picker(L10n.string("app.workflows.editor.input", fallback: "Input"), selection: $step.input) {
                        ForEach(WorkflowStepInput.allCases, id: \.self) { input in
                            Text(input.displayName).tag(input)
                        }
                    }

                    Button(role: .destructive) {
                        viewModel.draft.steps.removeAll(where: { $0.id == step.id })
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }

            HStack {
                Button(L10n.string("app.workflows.editor.addStep", fallback: "Add Step"), action: viewModel.addStep)
                Spacer()
                Button(L10n.string("app.workflows.editor.save", fallback: "Save"), action: viewModel.saveDraft)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 720)
    }
}
