import Foundation

public enum BuiltinActionIdentifier {
    public static let openInEditor = "builtin.open-editor"
    public static let terminalPrefix = "builtin.open-terminal."

    public static func openInTerminalActionID(for launcher: AppLauncher) -> String {
        terminalPrefix + launcher.id
    }

    public static func isOpenInTerminalActionID(_ actionID: String) -> Bool {
        actionID.hasPrefix(terminalPrefix)
    }
}
