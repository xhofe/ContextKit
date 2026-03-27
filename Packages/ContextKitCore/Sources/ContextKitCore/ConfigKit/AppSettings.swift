import Foundation

public struct AppSettings: Codable, Hashable, Sendable {
    public var monitoredRoots: [MonitoredRoot]
    public var defaultTerminal: AppLauncher
    public var defaultEditor: AppLauncher
    public var disabledActionIDs: [String]
    public var orderedActionIDs: [String]
    public var trustedPlugins: [TrustedPluginGrant]
    public var language: AppLanguage

    enum CodingKeys: String, CodingKey {
        case monitoredRoots
        case defaultTerminal
        case defaultEditor
        case disabledActionIDs
        case orderedActionIDs
        case trustedPlugins
        case language
    }

    public init(
        monitoredRoots: [MonitoredRoot] = [],
        defaultTerminal: AppLauncher = .terminalDefault,
        defaultEditor: AppLauncher = .editorDefault,
        disabledActionIDs: [String] = [],
        orderedActionIDs: [String] = [],
        trustedPlugins: [TrustedPluginGrant] = [],
        language: AppLanguage = .system
    ) {
        self.monitoredRoots = monitoredRoots
        self.defaultTerminal = defaultTerminal
        self.defaultEditor = defaultEditor
        self.disabledActionIDs = disabledActionIDs
        self.orderedActionIDs = orderedActionIDs
        self.trustedPlugins = trustedPlugins
        self.language = language
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        monitoredRoots = try container.decodeIfPresent([MonitoredRoot].self, forKey: .monitoredRoots) ?? []
        defaultTerminal = try container.decodeIfPresent(AppLauncher.self, forKey: .defaultTerminal) ?? .terminalDefault
        defaultEditor = try container.decodeIfPresent(AppLauncher.self, forKey: .defaultEditor) ?? .editorDefault
        disabledActionIDs = try container.decodeIfPresent([String].self, forKey: .disabledActionIDs) ?? []
        orderedActionIDs = try container.decodeIfPresent([String].self, forKey: .orderedActionIDs) ?? []
        trustedPlugins = try container.decodeIfPresent([TrustedPluginGrant].self, forKey: .trustedPlugins) ?? []
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .system
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(monitoredRoots, forKey: .monitoredRoots)
        try container.encode(defaultTerminal, forKey: .defaultTerminal)
        try container.encode(defaultEditor, forKey: .defaultEditor)
        try container.encode(disabledActionIDs, forKey: .disabledActionIDs)
        try container.encode(orderedActionIDs, forKey: .orderedActionIDs)
        try container.encode(trustedPlugins, forKey: .trustedPlugins)
        try container.encode(language, forKey: .language)
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
