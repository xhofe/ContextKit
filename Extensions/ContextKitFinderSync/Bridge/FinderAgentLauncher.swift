import AppKit
import Foundation

struct FinderAgentLauncher {
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
        let isRunning = !NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).isEmpty
        guard !isRunning else {
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        configuration.addsToRecentItems = false

        workspace.openApplication(at: agentURL, configuration: configuration) { _, error in
            if let error {
                NSLog("ContextKitFinderSync failed to launch agent: %@", error.localizedDescription)
            }
        }
    }

    private func agentURL(for hostBundle: Bundle) -> URL? {
        let candidateURLs = [
            hostBundle.bundleURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(path: "Contents/Library/LoginItems/ContextKitAgent.app", directoryHint: .isDirectory),
            hostBundle.bundleURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(path: "Library/LoginItems/ContextKitAgent.app", directoryHint: .isDirectory),
        ]

        return candidateURLs.first(where: { fileManager.fileExists(atPath: $0.path) })
    }
}
