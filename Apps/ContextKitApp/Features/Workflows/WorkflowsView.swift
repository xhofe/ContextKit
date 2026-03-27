import ContextKitCore
import SwiftUI

struct WorkflowsView: View {
    @ObservedObject var viewModel: WorkflowsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(
                    L10n.string(
                        "app.workflows.description",
                        fallback: "Build linear workflows that chain built-in actions and trusted plugins."
                    )
                )
                    .foregroundStyle(.secondary)
                Spacer()
                Button(L10n.string("app.workflows.new", fallback: "New Workflow"), action: viewModel.createWorkflow)
            }

            List(viewModel.workflows, id: \.id) { workflow in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(workflow.name)
                            .font(.headline)
                        Spacer()
                        Button(L10n.string("app.workflows.edit", fallback: "Edit")) {
                            viewModel.edit(workflow)
                        }
                        Button(L10n.string("app.workflows.delete", fallback: "Delete"), role: .destructive) {
                            viewModel.remove(workflow)
                        }
                    }
                    Text(workflow.steps.map(\.actionID).joined(separator: " → "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .listStyle(.inset)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .padding(24)
        .navigationTitle(L10n.string("app.workflows.navigation", fallback: "Workflows"))
        .sheet(isPresented: $viewModel.isPresentingEditor) {
            WorkflowEditorView(viewModel: viewModel)
        }
        .onAppear(perform: viewModel.reload)
    }
}
