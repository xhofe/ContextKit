import Foundation
import ContextKitCore

public enum BuiltinActionRegistry {
    public static func commands() -> [AnyActionCommand] {
        let baseCommands = [
            CopyPathAction().command,
            CopyRelativePathAction().command,
            CopyMD5Action().command,
            CopySHA256Action().command,
            CompressAction().command,
            ExtractAction().command,
        ]

        let terminalCommands = AppLauncher.knownTerminalLaunchers.map { launcher in
            OpenInTerminalAction(launcher: launcher).command
        }
        let editorCommands = AppLauncher.knownEditorLaunchers.map { launcher in
            OpenInEditorAction(launcher: launcher).command
        }

        return terminalCommands + editorCommands + baseCommands
    }
}
