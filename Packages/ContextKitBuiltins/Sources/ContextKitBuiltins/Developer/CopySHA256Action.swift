import Foundation
import ContextKitCore

struct CopySHA256Action {
    private let clipboardWriter = ClipboardWriter()
    private let fileHasher = FileHasher()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.copy-sha256",
                name: "复制 SHA256",
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(allowDirectories: false),
                capabilities: [.clipboard],
                resultPolicy: ActionResultPolicy(deliversClipboard: true)
            )
        ) { context in
            let lines = try context.request.selectedURLs.map { url in
                "\(try self.fileHasher.sha256(for: url))  \(url.lastPathComponent)"
            }
            let content = lines.joined(separator: "\n")
            self.clipboardWriter.copy(content)
            return ExecutionResult(status: .success, message: "Copied SHA256 hash(es).", clipboardText: content)
        }
    }
}
