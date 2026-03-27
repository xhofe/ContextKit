import Foundation
import ContextKitCore

struct CompressAction {
    private let archiveRunner = ArchiveCommandRunner()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.compress",
                name: "压缩",
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(),
                capabilities: [.subprocess, .writeGeneratedFiles],
                resultPolicy: ActionResultPolicy(deliversFiles: true)
            )
        ) { context in
            guard let firstURL = context.request.selectedURLs.first else {
                return ExecutionResult(status: .skipped, message: "Nothing selected.")
            }

            let outputName = context.request.selectedURLs.count == 1
                ? "\(firstURL.deletingPathExtension().lastPathComponent).zip"
                : "ContextKit-Archive.zip"
            let outputURL = firstURL.deletingLastPathComponent().appending(path: outputName)
            try self.archiveRunner.zip(inputURLs: context.request.selectedURLs, outputURL: outputURL)

            return ExecutionResult(
                status: .success,
                message: "Archive created.",
                producedURLs: [outputURL]
            )
        }
    }
}
