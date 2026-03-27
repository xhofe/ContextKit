import ContextKitCore
import SwiftUI

struct OverviewView: View {
    @ObservedObject var viewModel: OverviewViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("ContextKit")
                    .font(.largeTitle.weight(.bold))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 16)], spacing: 16) {
                    InfoChip(title: L10n.string("app.overview.actions", fallback: "Actions"), value: "\(viewModel.actionCount)")
                    InfoChip(title: L10n.string("app.overview.plugins", fallback: "Plugins"), value: "\(viewModel.pluginCount)")
                    InfoChip(title: L10n.string("app.overview.workflows", fallback: "Workflows"), value: "\(viewModel.workflowCount)")
                    InfoChip(title: L10n.string("app.overview.monitoredRoots", fallback: "Monitored Roots"), value: "\(viewModel.monitoredRootCount)")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.string("app.overview.recentActivity", fallback: "Recent Activity"))
                        .font(.title3.weight(.semibold))
                    if viewModel.recentLogs.isEmpty {
                        EmptyStateView(
                            title: L10n.string("app.overview.emptyTitle", fallback: "No activity yet"),
                            message: L10n.string(
                                "app.overview.emptyMessage",
                                fallback: "Run an action from the app, CLI, or Finder extension and recent results will appear here."
                            )
                        )
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
        .navigationTitle(L10n.string("app.overview.navigation", fallback: "Overview"))
        .onAppear(perform: viewModel.reload)
    }
}
