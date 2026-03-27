import SwiftUI

struct OverviewView: View {
    @ObservedObject var viewModel: OverviewViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("ContextKit")
                    .font(.largeTitle.weight(.bold))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 16)], spacing: 16) {
                    InfoChip(title: "Actions", value: "\(viewModel.actionCount)")
                    InfoChip(title: "Plugins", value: "\(viewModel.pluginCount)")
                    InfoChip(title: "Workflows", value: "\(viewModel.workflowCount)")
                    InfoChip(title: "Monitored Roots", value: "\(viewModel.monitoredRootCount)")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.title3.weight(.semibold))
                    if viewModel.recentLogs.isEmpty {
                        EmptyStateView(title: "No activity yet", message: "Run an action from the app, CLI, or Finder extension and recent results will appear here.")
                            .frame(height: 220)
                    } else {
                        ForEach(viewModel.recentLogs) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.request.targetId)
                                    .font(.headline)
                                Text(entry.result.message)
                                    .foregroundStyle(.secondary)
                                Text(entry.completedAt.formatted(date: .numeric, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.quinary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .padding(28)
        }
        .navigationTitle("Overview")
        .onAppear(perform: viewModel.reload)
    }
}
