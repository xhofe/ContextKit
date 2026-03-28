import Foundation

public enum BuiltinActionIdentifier {
    public static let terminalPrefix = "builtin.open-terminal."
    public static let editorPrefix = "builtin.open-editor."

    public static func openInTerminalActionID(for launcher: AppLauncher) -> String {
        terminalPrefix + launcher.id
    }

    public static func openInEditorActionID(for launcher: AppLauncher) -> String {
        editorPrefix + launcher.id
    }

    public static func isOpenInTerminalActionID(_ actionID: String) -> Bool {
        actionID.hasPrefix(terminalPrefix)
    }

    public static func isOpenInEditorActionID(_ actionID: String) -> Bool {
        actionID.hasPrefix(editorPrefix)
    }
}
