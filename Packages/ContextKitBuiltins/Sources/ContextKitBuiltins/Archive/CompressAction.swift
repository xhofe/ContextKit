import Foundation
import ContextKitCore

struct CompressAction {
    private let archiveRunner = ArchiveCommandRunner()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.compress",
                name: L10n.string("builtin.compress.name", fallback: "Compress"),
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(),
                capabilities: [.subprocess, .writeGeneratedFiles],
                resultPolicy: ActionResultPolicy(deliversFiles: true)
            )
        ) { context in
            guard let firstURL = context.request.selectedURLs.first else {
                return ExecutionResult(
                    status: .skipped,
                    message: L10n.string("builtin.compress.nothingSelected", fallback: "Nothing selected.")
                )
            }

            let outputName = context.request.selectedURLs.count == 1
                ? "\(firstURL.deletingPathExtension().lastPathComponent).zip"
                : L10n.string("builtin.compress.defaultArchiveName", fallback: "ContextKit-Archive.zip")
            let outputURL = firstURL.deletingLastPathComponent().appending(path: outputName)
            try self.archiveRunner.zip(inputURLs: context.request.selectedURLs, outputURL: outputURL)

            return ExecutionResult(
                status: .success,
                message: L10n.string("builtin.compress.created", fallback: "Archive created."),
                producedURLs: [outputURL]
            )
        }
    }
}
