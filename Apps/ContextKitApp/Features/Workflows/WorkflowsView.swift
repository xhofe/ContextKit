import SwiftUI

struct WorkflowsView: View {
    @ObservedObject var viewModel: WorkflowsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Build linear workflows that chain built-in actions and trusted plugins.")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("New Workflow", action: viewModel.createWorkflow)
            }

            List(viewModel.workflows, id: \.id) { workflow in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(workflow.name)
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            viewModel.edit(workflow)
                        }
                        Button("Delete", role: .destructive) {
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
        .navigationTitle("Workflows")
        .sheet(isPresented: $viewModel.isPresentingEditor) {
            WorkflowEditorView(viewModel: viewModel)
        }
        .onAppear(perform: viewModel.reload)
    }
}
