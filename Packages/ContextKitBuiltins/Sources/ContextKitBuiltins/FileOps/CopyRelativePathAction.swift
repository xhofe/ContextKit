import Foundation
import ContextKitCore

struct CopyRelativePathAction {
    private let calculator = RelativePathCalculator()
    private let clipboardWriter = ClipboardWriter()

    var command: AnyActionCommand {
        AnyActionCommand(
            manifest: ActionManifest(
                id: "builtin.copy-relative-path",
                name: "复制相对路径",
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
                message: "Copied relative path(s).",
                clipboardText: content
            )
        }
    }
}
