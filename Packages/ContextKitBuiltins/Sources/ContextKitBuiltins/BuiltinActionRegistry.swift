import Foundation
import ContextKitCore

public enum BuiltinActionRegistry {
    public static func commands() -> [AnyActionCommand] {
        let baseCommands = [
            CopyPathAction().command,
            CopyRelativePathAction().command,
            OpenInEditorAction().command,
            CopyMD5Action().command,
            CopySHA256Action().command,
            CompressAction().command,
            ExtractAction().command,
        ]

        let terminalCommands = AppLauncher.knownTerminalLaunchers.map { launcher in
            OpenInTerminalAction(launcher: launcher).command
        }

        return terminalCommands + baseCommands
    }
}
