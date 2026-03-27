import AppKit
import Foundation

@MainActor
final class EmbeddedAgentLauncher {
    private let workspace: NSWorkspace
    private let fileManager: FileManager

    init(
        workspace: NSWorkspace = .shared,
        fileManager: FileManager = .default
    ) {
        self.workspace = workspace
        self.fileManager = fileManager
    }

    func launchIfNeeded(hostBundle: Bundle = .main) {
        guard let agentURL = agentURL(for: hostBundle) else {
            return
        }

        let bundleIdentifier = Bundle(url: agentURL)?.bundleIdentifier ?? "ci.nn.ContextKit.Agent"
        guard NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).isEmpty else {
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        configuration.addsToRecentItems = false

        workspace.openApplication(at: agentURL, configuration: configuration) { _, error in
            if let error {
                NSLog("ContextKit failed to launch agent: %@", error.localizedDescription)
            }
        }
    }

    private func agentURL(for hostBundle: Bundle) -> URL? {
        let candidateURLs = [
            hostBundle.bundleURL.appending(path: "Contents/Library/LoginItems/ContextKitAgent.app", directoryHint: .isDirectory),
            hostBundle.bundleURL.deletingLastPathComponent().appending(path: "ContextKitAgent.app", directoryHint: .isDirectory),
        ]

        return candidateURLs.first(where: { fileManager.fileExists(atPath: $0.path) })
    }
}
