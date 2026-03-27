import Foundation

public final class PluginRepository: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let settingsStore: SharedSettingsStore
    private let trustEvaluator: PluginTrustEvaluator
    private let manifestLoader = ActionManifestLoader()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider(),
        settingsStore: SharedSettingsStore = SharedSettingsStore(),
        trustEvaluator: PluginTrustEvaluator = PluginTrustEvaluator()
    ) {
        self.directoryProvider = directoryProvider
        self.settingsStore = settingsStore
        self.trustEvaluator = trustEvaluator
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func installedPlugins() throws -> [InstalledPlugin] {
        let settings = try settingsStore.load()
        let directory = try directoryProvider.pluginsDirectoryURL()
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        return try urls
            .filter(\.hasDirectoryPath)
            .compactMap { try installedPlugin(at: $0, settings: settings) }
            .sorted(by: { $0.package.manifest.name.localizedCaseInsensitiveCompare($1.package.manifest.name) == .orderedAscending })
    }

    public func installedPlugin(id: String) throws -> InstalledPlugin? {
        try installedPlugins().first(where: { $0.id == id })
    }

    public func trust(pluginID: String) throws {
        guard let plugin = try installedPlugin(id: pluginID) else {
            return
        }

        var settings = try settingsStore.load()
        settings.trustedPlugins.removeAll(where: { $0.pluginID == pluginID })
        settings.trustedPlugins.append(
            TrustedPluginGrant(
                pluginID: pluginID,
                capabilities: plugin.package.manifest.capabilities,
                sourceDescription: plugin.installationRecord.sourceDescription,
                revision: plugin.installationRecord.revision
            )
        )
        try settingsStore.save(settings)
    }

    public func remove(pluginID: String) throws {
        guard let plugin = try installedPlugin(id: pluginID) else {
            return
        }
        try FileManager.default.removeItem(at: plugin.package.rootURL)
    }

    public func install(from sourceDirectory: URL, sourceKind: PluginSourceKind, sourceDescription: String, revision: String? = nil) throws -> InstalledPlugin {
        let package = try PluginPackage.load(from: sourceDirectory, loader: manifestLoader)
        let destinationURL = try pluginRootURL(for: package.manifest.id)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.copyItem(at: sourceDirectory, to: destinationURL)

        let record = PluginInstallationRecord(
            pluginID: package.manifest.id,
            sourceKind: sourceKind,
            sourceDescription: sourceDescription,
            revision: revision
        )
        let recordData = try encoder.encode(record)
        try recordData.write(to: destinationURL.appending(path: PluginPackage.installationRecordName), options: .atomic)

        let settings = try settingsStore.load()
        let installedPackage = try PluginPackage.load(from: destinationURL, loader: manifestLoader)
        let trustDiff = trustEvaluator.diff(
            for: installedPackage.manifest,
            grant: settings.trustedPlugins.first(where: { $0.pluginID == installedPackage.manifest.id })
        )

        return InstalledPlugin(
            package: installedPackage,
            installationRecord: record,
            trustDiff: trustDiff
        )
    }

    private func installedPlugin(at url: URL, settings: AppSettings) throws -> InstalledPlugin? {
        guard FileManager.default.fileExists(atPath: url.appending(path: PluginPackage.manifestName).path) else {
            return nil
        }

        let package = try PluginPackage.load(from: url, loader: manifestLoader)
        let recordData = try Data(contentsOf: package.installationRecordURL)
        let record = try decoder.decode(PluginInstallationRecord.self, from: recordData)
        let grant = settings.trustedPlugins.first(where: { $0.pluginID == package.manifest.id })
        let diff = trustEvaluator.diff(for: package.manifest, grant: grant)
        return InstalledPlugin(package: package, installationRecord: record, trustDiff: diff)
    }

    private func pluginRootURL(for pluginID: String) throws -> URL {
        let sanitized = pluginID.replacingOccurrences(
            of: #"[^A-Za-z0-9\-_\.]"#,
            with: "-",
            options: .regularExpression
        )
        return try directoryProvider.pluginsDirectoryURL().appending(path: sanitized, directoryHint: .isDirectory)
    }
}
