import Foundation
import ContextKitCore

struct OpenInTerminalAction {
    let launcher: AppLauncher
    private let opener = LauncherOpener()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: BuiltinActionIdentifier.openInTerminalActionID(for: launcher),
                name: launcher.name,
                category: .open,
                kind: .builtin,
                contextRules: ContextRules(),
                capabilities: [.openApp]
            )
        ) { context in
            let targetURL = context.request.selectedURLs.first.map {
                $0.hasDirectoryPath ? $0 : $0.deletingLastPathComponent()
            } ?? context.monitoredRootURL

            guard let targetURL else {
                return ExecutionResult(
                    status: .skipped,
                    message: L10n.string("builtin.openTerminal.noDirectory", fallback: "No directory available to open.")
                )
            }

            try self.opener.open([targetURL], with: launcher)
            return ExecutionResult(
                status: .success,
                message: String(
                    format: L10n.string("builtin.openTerminal.openedNamed", fallback: "Opened %@."),
                    launcher.name
                )
            )
        }
    }
}
