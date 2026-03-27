import Foundation
import ContextKitCore

struct CopyMD5Action {
    private let clipboardWriter = ClipboardWriter()
    private let fileHasher = FileHasher()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.copy-md5",
                name: L10n.string("builtin.copyMD5.name", fallback: "Copy MD5"),
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(allowDirectories: false),
                capabilities: [.clipboard],
                resultPolicy: ActionResultPolicy(deliversClipboard: true)
            )
        ) { context in
            let lines = try context.request.selectedURLs.map { url in
                "\(try self.fileHasher.md5(for: url))  \(url.lastPathComponent)"
            }
            let content = lines.joined(separator: "\n")
            self.clipboardWriter.copy(content)
            return ExecutionResult(
                status: .success,
                message: L10n.string("builtin.copyMD5.message", fallback: "Copied MD5 hash(es)."),
                clipboardText: content
            )
        }
    }
}
