import Foundation
import ContextKitCore

struct CopyRelativePathAction {
    private let calculator = RelativePathCalculator()
    private let clipboardWriter = ClipboardWriter()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.copy-relative-path",
                name: L10n.string("builtin.copyRelativePath.name", fallback: "Copy Relative Path"),
                category: .tools,
                kind: .builtin,
                contextRules: ContextRules(requireSameRoot: true),
                capabilities: [.clipboard],
                resultPolicy: ActionResultPolicy(deliversClipboard: true)
            )
        ) { context in
            guard let rootURL = context.monitoredRootURL else {
                throw RelativePathError.outsideRoot(context.request.selectedURLs.first ?? URL(fileURLWithPath: "/"))
            }
            let relativePaths = try self.calculator.relativePaths(for: context.request.selectedURLs, within: rootURL)
            let content = relativePaths.joined(separator: "\n")
            self.clipboardWriter.copy(content)
            return ExecutionResult(
                status: .success,
                message: L10n.string("builtin.copyRelativePath.message", fallback: "Copied relative path(s)."),
                clipboardText: content
            )
        }
    }
}
