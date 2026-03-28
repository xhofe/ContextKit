import Foundation
import ContextKitCore

struct OpenInEditorAction {
    let launcher: AppLauncher
    private let opener = LauncherOpener()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: BuiltinActionIdentifier.openInEditorActionID(for: launcher),
                name: launcher.name,
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

            try self.opener.open(targets, with: launcher)
            return ExecutionResult(
                status: .success,
                message: String(
                    format: L10n.string("builtin.openEditor.openedNamed", fallback: "Opened %@."),
                    launcher.name
                )
            )
        }
    }
}
