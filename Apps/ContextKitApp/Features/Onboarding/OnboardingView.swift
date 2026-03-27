import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Choose your first monitored root")
                .font(.largeTitle.weight(.bold))
            Text("Finder Sync can only surface ContextKit menus inside monitored roots, so v1 starts by letting you choose the workspaces that should participate.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: 560, alignment: .leading)
            Button("Add Monitored Root", action: viewModel.addRoot)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(40)
    }
}
