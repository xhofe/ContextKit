import SwiftUI

@main
struct ContextKitMacApp: App {
    @NSApplicationDelegateAdaptor(ContextKitAppDelegate.self) private var appDelegate
    @State private var container = ContextKitAppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .task {
                    do {
                        try container.services.bootstrap()
                    } catch {
                        container.overviewViewModel.errorMessage = error.localizedDescription
                    }
                    container.reloadAll()
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1120, height: 720)
    }
}
