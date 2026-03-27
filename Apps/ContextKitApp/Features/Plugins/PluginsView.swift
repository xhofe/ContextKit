import SwiftUI

struct PluginsView: View {
    @ObservedObject var viewModel: PluginsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Install")
                    .font(.title3.weight(.semibold))
                HStack {
                    Button("Import Local Plugin", action: viewModel.installLocalPlugin)
                    TextField("https://github.com/example/plugin.git", text: $viewModel.gitRepositoryURL)
                    Button("Install from Git", action: viewModel.installGitPlugin)
                }
            }

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .foregroundStyle(.secondary)
            }

            List(viewModel.plugins, id: \.id) { plugin in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(plugin.package.manifest.name)
                            .font(.headline)
                        Spacer()
                        Text(plugin.isTrusted ? "Trusted" : "Needs Trust")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(plugin.isTrusted ? Color.green.opacity(0.16) : Color.orange.opacity(0.2), in: Capsule())
                    }

                    Text(plugin.installationRecord.sourceDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(plugin.package.manifest.capabilities.map(\.displayName).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        if !plugin.isTrusted {
                            Button("Trust") {
                                viewModel.trust(plugin)
                            }
                        }
                        Button("Remove", role: .destructive) {
                            viewModel.remove(plugin)
                        }
                    }
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
        .navigationTitle("Plugins")
        .onAppear(perform: viewModel.reload)
    }
}
