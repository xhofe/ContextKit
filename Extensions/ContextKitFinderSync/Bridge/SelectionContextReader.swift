import ContextKitCore
import FinderSync
import Foundation

struct SelectionContext: Sendable {
    var selectedURLs: [URL]
    var targetedURL: URL?
}

struct SelectionContextReader {
    func read(from controller: FIFinderSyncController) -> SelectionContext? {
        let selectedURLs = controller.selectedItemURLs() ?? []
        let targetedURL = controller.targetedURL()
        let effectiveSelection = selectedURLs.isEmpty ? [targetedURL].compactMap { $0 } : selectedURLs

        guard !effectiveSelection.isEmpty else {
            return nil
        }

        return SelectionContext(
            selectedURLs: selectedURLs,
            targetedURL: targetedURL
        )
    }

    func makeRequest(from selection: SelectionContext) -> FinderSelectionRequest {
        FinderSelectionRequest(
            selectedPaths: selection.selectedURLs.map(\.path),
            targetedPath: selection.targetedURL?.path,
            currentDirectoryPath: selection.targetedURL?.path
        )
    }

    func makeExecutionRequest(
        targetID: String,
        targetType: TargetType,
        selection: SelectionContext
    ) -> FinderExecutionRequest {
        FinderExecutionRequest(
            targetID: targetID,
            targetType: targetType,
            selectedPaths: selection.selectedURLs.map(\.path),
            targetedPath: selection.targetedURL?.path,
            currentDirectoryPath: selection.targetedURL?.path
        )
    }
}
