import Foundation
import ContextKitCore

struct CopyPathAction {
    private let clipboardWriter = ClipboardWriter()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.copy-path",
                name: L10n.string("builtin.copyPath.name", fallback: "Copy Path"),
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(),
                capabilities: [.clipboard],
                resultPolicy: ActionResultPolicy(deliversClipboard: true)
            )
        ) { context in
            let content = context.request.selectedURLs.map(\.path).joined(separator: "\n")
            self.clipboardWriter.copy(content)
            return ExecutionResult(
                status: .success,
                message: L10n.string(
                    "builtin.copyPath.message",
                    fallback: "Copied %lld path(s).",
                    Int64(context.request.selectedURLs.count)
                ),
                clipboardText: content
            )
        }
    }
}
