import Foundation
import ContextKitCore

struct OpenInTerminalAction {
    private let opener = LauncherOpener()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.open-terminal",
                name: "在终端打开",
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
                return ExecutionResult(status: .skipped, message: "No directory available to open.")
            }

            try self.opener.open([targetURL], with: context.settings.defaultTerminal)
            return ExecutionResult(status: .success, message: "Opened terminal.")
        }
    }
}
