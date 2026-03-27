import Foundation
import ContextKitCore

public enum BuiltinActionRegistry {
    public static func commands() -> [AnyActionCommand] {
        [
            CopyPathAction().command,
            CopyRelativePathAction().command,
            OpenInTerminalAction().command,
            OpenInEditorAction().command,
            CopyMD5Action().command,
            CopySHA256Action().command,
            CompressAction().command,
            ExtractAction().command,
        ]
    }
}
