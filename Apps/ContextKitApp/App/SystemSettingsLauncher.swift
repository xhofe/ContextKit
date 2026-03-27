import AppKit
import Foundation

struct SystemSettingsLauncher {
    private let workspace: NSWorkspace

    init(workspace: NSWorkspace = .shared) {
        self.workspace = workspace
    }

    func openFinderExtensionsSettings() -> Bool {
        let candidateURLs = [
            URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"),
            URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences"),
            URL(fileURLWithPath: "/System/Applications/System Settings.app"),
        ].compactMap { $0 }

        for url in candidateURLs where workspace.open(url) {
            return true
        }

        return false
    }
}
