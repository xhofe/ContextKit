import Foundation
import ContextKitCore

struct OpenInEditorAction {
    private let opener = LauncherOpener()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: BuiltinActionIdentifier.openInEditor,
                name: L10n.string("builtin.openEditor.name", fallback: "Open in Editor"),
                category: .open,
                kind: .builtin,
                contextRules: ContextRules(),
                capabilities: [.openApp]
            )
        ) { context in
            let targets = context.request.selectedURLs.isEmpty ? (context.monitoredRootURL.map { [$0] } ?? []) : context.request.selectedURLs
            guard !targets.isEmpty else {
                return ExecutionResult(
                    status: .skipped,
                    message: L10n.string("builtin.openEditor.noItem", fallback: "No item available to open.")
                )
            }

            try self.opener.open(targets, with: context.settings.defaultEditor)
            return ExecutionResult(status: .success, message: L10n.string("builtin.openEditor.opened", fallback: "Opened editor."))
        }
    }
}
