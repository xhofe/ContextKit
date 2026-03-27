import Foundation
import ContextKitCore

struct CopyPathAction {
    private let clipboardWriter = ClipboardWriter()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.copy-path",
                name: "复制路径",
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
                message: "Copied \(context.request.selectedURLs.count) path(s).",
                clipboardText: content
            )
        }
    }
}
