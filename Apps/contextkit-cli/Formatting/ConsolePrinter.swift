import ContextKitCore
import Foundation

struct ConsolePrinter {
    func printResult(_ result: ExecutionResult) {
        Swift.print(result.message)
        if let clipboardText = result.clipboardText, !clipboardText.isEmpty {
            Swift.print("\nClipboard:\n\(clipboardText)")
        }
        if !result.producedURLs.isEmpty {
            Swift.print("\nProduced:")
            result.producedURLs.forEach { Swift.print($0.path) }
        }
        if !result.logs.isEmpty {
            Swift.print("\nLogs:")
            result.logs.forEach { Swift.print("[\($0.level)] \($0.message)") }
        }
    }

    func printPlugins(_ plugins: [InstalledPlugin]) {
        if plugins.isEmpty {
            Swift.print("No plugins installed.")
            return
        }

        for plugin in plugins {
            Swift.print("\(plugin.package.manifest.id)\t\(plugin.package.manifest.name)\t\(plugin.isTrusted ? "trusted" : "needs-trust")")
        }
    }

    func printLogs(_ entries: [ExecutionLogEntry]) {
        if entries.isEmpty {
            Swift.print("No execution logs found.")
            return
        }

        for entry in entries {
            Swift.print("[\(entry.completedAt.formatted(date: .numeric, time: .standard))] \(entry.request.targetId): \(entry.result.message)")
        }
    }

    func printError(_ error: Error) {
        fputs("Error: \(error.localizedDescription)\n", stderr)
    }
}
