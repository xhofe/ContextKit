import Foundation
import ContextKitCore

struct ExtractAction {
    private let archiveRunner = ArchiveCommandRunner()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.extract",
                name: L10n.string("builtin.extract.name", fallback: "Extract"),
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(
                    allowDirectories: false,
                    maxSelection: 1,
                    allowedUTTypes: ["public.zip-archive"]
                ),
                capabilities: [.subprocess, .writeGeneratedFiles],
                resultPolicy: ActionResultPolicy(deliversFiles: true)
            )
        ) { context in
            guard let archiveURL = context.request.selectedURLs.first else {
                return ExecutionResult(
                    status: .skipped,
                    message: L10n.string("builtin.extract.nothingSelected", fallback: "Nothing selected.")
                )
            }

            let outputDirectoryURL = archiveURL.deletingLastPathComponent().appending(path: archiveURL.deletingPathExtension().lastPathComponent, directoryHint: .isDirectory)
            try FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true)
            try self.archiveRunner.unzip(inputURL: archiveURL, outputDirectoryURL: outputDirectoryURL)

            return ExecutionResult(
                status: .success,
                message: L10n.string("builtin.extract.extracted", fallback: "Archive extracted."),
                producedURLs: [outputDirectoryURL]
            )
        }
    }
}
