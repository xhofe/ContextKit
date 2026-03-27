import ContextKitCore
import FinderSync
import Foundation

struct SelectionContext: Sendable {
    var selectedURLs: [URL]
    var monitoredRootURL: URL?
    var snapshot: ContextSnapshot
}

struct SelectionContextReader {
    private let settingsStore = SharedSettingsStore()

    func read(from controller: FIFinderSyncController) -> SelectionContext? {
        let selectedURLs = controller.selectedItemURLs() ?? {
            if let targetedURL = controller.targetedURL() {
                return [targetedURL]
            }
            return nil
        }()

        guard let selectedURLs, !selectedURLs.isEmpty else {
            return nil
        }

        let settings = try? settingsStore.load()
        let monitoredRootURL = settings?.monitoredRoot(for: selectedURLs.first)
        let snapshot = ContextSnapshot(selectedURLs: selectedURLs, monitoredRootURL: monitoredRootURL)
        return SelectionContext(selectedURLs: selectedURLs, monitoredRootURL: monitoredRootURL, snapshot: snapshot)
    }
}
