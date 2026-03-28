import ContextKitCore
import SwiftUI

struct WorkflowStepRowView: View {
    @Binding var step: WorkflowDraftStep
    let availableActions: [ActionManifest]
    let removeStep: () -> Void

    var body: some View {
        HStack {
            Picker(L10n.string("app.workflows.editor.action", fallback: "Action"), selection: $step.actionID) {
                ForEach(availableActions, id: \.id) { action in
                    Text(action.name).tag(action.id)
                }
            }

            Picker(L10n.string("app.workflows.editor.input", fallback: "Input"), selection: $step.input) {
                ForEach(WorkflowStepInput.allCases, id: \.self) { input in
                    Text(input.displayName).tag(input)
                }
            }

            Button("Remove Step", systemImage: "trash", role: .destructive, action: removeStep)
                .labelStyle(.iconOnly)
        }
    }
}
