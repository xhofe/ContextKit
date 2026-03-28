import ContextKitCore
import Observation
import SwiftUI

struct WorkflowEditorView: View {
    @Bindable var viewModel: WorkflowsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            TextField(L10n.string("app.workflows.editor.namePlaceholder", fallback: "Workflow name"), text: $viewModel.draft.name)
                .textFieldStyle(.roundedBorder)

            ForEach($viewModel.draft.steps) { $step in
                WorkflowStepRowView(
                    step: $step,
                    availableActions: viewModel.availableActions,
                    removeStep: {
                        viewModel.draft.steps.removeAll(where: { $0.id == step.id })
                    }
                )
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
