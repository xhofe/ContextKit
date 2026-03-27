import ContextKitCore
import Foundation

struct ConsolePrinter {
    func printResult(_ result: ExecutionResult) {
        Swift.print(result.message)
        if let clipboardText = result.clipboardText, !clipboardText.isEmpty {
            Swift.print("\n\(L10n.string("cli.header.clipboard", fallback: "Clipboard")):\n\(clipboardText)")
        }
        if !result.producedURLs.isEmpty {
            Swift.print("\n\(L10n.string("cli.header.produced", fallback: "Produced")):")
            result.producedURLs.forEach { Swift.print($0.path) }
        }
        if !result.logs.isEmpty {
            Swift.print("\n\(L10n.string("cli.header.logs", fallback: "Logs")):")
            result.logs.forEach { Swift.print("[\($0.level)] \($0.message)") }
        }
    }

    func printPlugins(_ plugins: [InstalledPlugin]) {
        if plugins.isEmpty {
            Swift.print(L10n.string("cli.plugins.none", fallback: "No plugins installed."))
            return
        }

        for plugin in plugins {
            let trustState = plugin.isTrusted
                ? L10n.string("cli.plugins.trusted", fallback: "trusted")
                : L10n.string("cli.plugins.needsTrust", fallback: "needs-trust")
            Swift.print("\(plugin.package.manifest.id)\t\(plugin.package.manifest.name)\t\(trustState)")
        }
    }

    func printLogs(_ entries: [ExecutionLogEntry]) {
        if entries.isEmpty {
            Swift.print(L10n.string("cli.logs.none", fallback: "No execution logs found."))
            return
        }

        for entry in entries {
            Swift.print("[\(entry.completedAt.formatted(date: .numeric, time: .standard))] \(entry.request.targetId): \(entry.result.message)")
        }
    }

    func printError(_ error: Error) {
        fputs(L10n.string("cli.error.prefix", fallback: "Error: %@\n", error.localizedDescription), stderr)
    }
}
