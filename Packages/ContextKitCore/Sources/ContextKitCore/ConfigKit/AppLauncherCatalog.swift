import Foundation

public extension AppLauncher {
    static let terminalIterm = AppLauncher(
        id: "terminal.iterm",
        name: "iTerm",
        bundleIdentifier: "com.googlecode.iterm2"
    )

    static let terminalWarp = AppLauncher(
        id: "terminal.warp",
        name: "Warp",
        bundleIdentifier: "dev.warp.Warp-Stable"
    )

    static let terminalGhostty = AppLauncher(
        id: "terminal.ghostty",
        name: "Ghostty",
        bundleIdentifier: "com.mitchellh.ghostty"
    )

    static let editorCursor = AppLauncher(
        id: "editor.cursor",
        name: "Cursor",
        bundleIdentifier: "com.todesktop.230313mzl4w4u92"
    )

    static let knownTerminalLaunchers: [AppLauncher] = [
        .terminalDefault,
        .terminalIterm,
        .terminalWarp,
        .terminalGhostty,
    ]

    static let knownEditorLaunchers: [AppLauncher] = [
        .editorDefault,
        .editorCursor,
    ]
}
