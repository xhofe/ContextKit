import Foundation

public struct AppSettings: Codable, Hashable, Sendable {
    public var monitoredRoots: [MonitoredRoot]
    public var defaultTerminal: AppLauncher
    public var defaultEditor: AppLauncher
    public var disabledActionIDs: [String]
    public var orderedActionIDs: [String]
    public var trustedPlugins: [TrustedPluginGrant]

    public init(
        monitoredRoots: [MonitoredRoot] = [],
        defaultTerminal: AppLauncher = .terminalDefault,
        defaultEditor: AppLauncher = .editorDefault,
        disabledActionIDs: [String] = [],
        orderedActionIDs: [String] = [],
        trustedPlugins: [TrustedPluginGrant] = []
    ) {
        self.monitoredRoots = monitoredRoots
        self.defaultTerminal = defaultTerminal
        self.defaultEditor = defaultEditor
        self.disabledActionIDs = disabledActionIDs
        self.orderedActionIDs = orderedActionIDs
        self.trustedPlugins = trustedPlugins
    }

    public func monitoredRoot(for url: URL?) -> URL? {
        guard let standardizedPath = url?.standardizedFileURL.path else {
            return monitoredRoots.first?.url
        }

        return monitoredRoots
            .map(\.url)
            .sorted { $0.path.count > $1.path.count }
            .first(where: { standardizedPath.hasPrefix($0.path) })
    }

    public func isActionEnabled(_ actionID: String) -> Bool {
        !disabledActionIDs.contains(actionID)
    }
}

public extension AppLauncher {
    static let terminalDefault = AppLauncher(
        id: "terminal.system",
        name: "Terminal",
        bundleIdentifier: "com.apple.Terminal"
    )

    static let editorDefault = AppLauncher(
        id: "editor.vscode",
        name: "Visual Studio Code",
        bundleIdentifier: "com.microsoft.VSCode"
    )
}
