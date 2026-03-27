import ContextKitCore
import SwiftUI

struct WorkflowEditorView: View {
    @ObservedObject var viewModel: WorkflowsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            TextField("Workflow name", text: $viewModel.draft.name)
                .textFieldStyle(.roundedBorder)

            ForEach($viewModel.draft.steps) { $step in
                HStack {
                    Picker("Action", selection: $step.actionID) {
                        ForEach(viewModel.availableActions, id: \.id) { action in
                            Text(action.name).tag(action.id)
                        }
                    }

                    Picker("Input", selection: $step.input) {
                        ForEach(WorkflowStepInput.allCases, id: \.self) { input in
                            Text(input.rawValue).tag(input)
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
                Button("Add Step", action: viewModel.addStep)
                Spacer()
                Button("Save", action: viewModel.saveDraft)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 720)
    }
}
