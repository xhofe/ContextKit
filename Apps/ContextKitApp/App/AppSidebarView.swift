import SwiftUI

struct AppSidebarView: View {
    @Binding var selection: AppScreen?

    var body: some View {
        List(AppScreen.allCases, selection: $selection) { screen in
            Label(screen.title, systemImage: screen.systemImage)
                .tag(screen)
        }
        .navigationTitle("ContextKit")
        .listStyle(.sidebar)
    }
}
