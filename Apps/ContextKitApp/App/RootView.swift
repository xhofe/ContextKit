import ContextKitCore
import SwiftUI

struct RootView: View {
    let container: ContextKitAppContainer
    @State private var selection: AppScreen? = .overview

    var body: some View {
        NavigationSplitView(
            sidebar: {
                AppSidebarView(selection: $selection)
            },
            detail: {
                AppDetailView(container: container, selection: selection)
            }
        )
        .frame(minWidth: 960, minHeight: 640)
        .environment(\.locale, container.settingsViewModel.settings.language.locale)
    }
}
