import ContextKitCore
import SwiftUI

struct OnboardingView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(L10n.string("app.onboarding.title", fallback: "Choose your first monitored root"))
                .font(.largeTitle.weight(.bold))
            Text(
                L10n.string(
                    "app.onboarding.description",
                    fallback: "Finder Sync can only surface ContextKit menus inside monitored roots, so v1 starts by letting you choose the workspaces that should participate."
                )
            )
                .foregroundStyle(.secondary)
                .frame(maxWidth: 560, alignment: .leading)
            Button(L10n.string("app.onboarding.addRoot", fallback: "Add Monitored Root"), action: viewModel.addRoot)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(40)
    }
}
