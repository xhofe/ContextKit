import AppKit
import ContextKitBuiltins
import ContextKitCore
import Foundation

@MainActor
final class ContextKitAppServices {
    let settingsStore: SharedSettingsStore
    let pluginRepository: PluginRepository
    let workflowRepository: WorkflowRepository
    let logStore: ExecutionLogStore

    private let localPluginInstaller: LocalPluginInstaller
    private let gitPluginInstaller: GitPluginInstaller
    private let executionCoordinator: ExecutionCoordinator
    private let bootstrapper: AppBootstrapper
    private let agentLauncher: EmbeddedAgentLauncher
    private let systemSettingsLauncher: SystemSettingsLauncher

    init() {
        let settingsStore = SharedSettingsStore()
        let pluginRepository = PluginRepository(settingsStore: settingsStore)
        let workflowRepository = WorkflowRepository()
        let logStore = ExecutionLogStore()

        self.settingsStore = settingsStore
        self.pluginRepository = pluginRepository
        self.workflowRepository = workflowRepository
        self.logStore = logStore
        self.localPluginInstaller = LocalPluginInstaller(pluginRepository: pluginRepository)
        self.gitPluginInstaller = GitPluginInstaller(pluginRepository: pluginRepository)
        self.executionCoordinator = ExecutionCoordinator(
            settingsStore: settingsStore,
            logStore: logStore,
            workflowRepository: workflowRepository,
            pluginRepository: pluginRepository,
            builtins: BuiltinActionRegistry.commands()
        )
        self.bootstrapper = AppBootstrapper(pluginRepository: pluginRepository)
        self.agentLauncher = EmbeddedAgentLauncher()
        self.systemSettingsLauncher = SystemSettingsLauncher()
    }

    func bootstrap(bundle: Bundle = .main) throws {
        try bootstrapper.installBundledPluginsIfNeeded(from: bundle)
        try executionCoordinator.refreshMenuCache()
        agentLauncher.launchIfNeeded(hostBundle: bundle)
    }

    func loadSettings() throws -> AppSettings {
        try settingsStore.load()
    }

    func saveSettings(_ settings: AppSettings) throws {
        try settingsStore.save(settings)
        L10n.invalidateCache()
        try executionCoordinator.refreshMenuCache()
    }

    func loadCatalog() throws -> RuntimeCatalog {
        try executionCoordinator.refreshMenuCache()
        return try executionCoordinator.catalog()
    }

    func loadPlugins() throws -> [InstalledPlugin] {
        try pluginRepository.installedPlugins()
    }

    func loadWorkflows() throws -> [WorkflowManifest] {
        try workflowRepository.list()
    }

    func loadLogs() throws -> [ExecutionLogEntry] {
        try logStore.load()
    }

    func toggleAction(_ actionID: String, enabled: Bool) throws {
        var settings = try settingsStore.load()
        settings.disabledActionIDs.removeAll(where: { $0 == actionID })
        if !enabled {
            settings.disabledActionIDs.append(actionID)
        }
        try saveSettings(settings)
    }

    func updateOrderedActionIDs(_ actionIDs: [String]) throws {
        var settings = try settingsStore.load()
        settings.orderedActionIDs = actionIDs
        try saveSettings(settings)
    }

    func addMonitoredRoot(url: URL) throws {
        var settings = try settingsStore.load()
        guard !settings.monitoredRoots.contains(where: { $0.path == url.path }) else {
            return
        }
        settings.monitoredRoots.append(MonitoredRoot(path: url.path, displayName: url.lastPathComponent))
        try saveSettings(settings)
    }

    func removeMonitoredRoot(_ root: MonitoredRoot) throws {
        var settings = try settingsStore.load()
        settings.monitoredRoots.removeAll(where: { $0.id == root.id })
        try saveSettings(settings)
    }

    func updateDefaultTerminal(_ launcher: AppLauncher) throws {
        var settings = try settingsStore.load()
        settings.defaultTerminal = launcher
        try saveSettings(settings)
    }

    func updateDefaultEditor(_ launcher: AppLauncher) throws {
        var settings = try settingsStore.load()
        settings.defaultEditor = launcher
        try saveSettings(settings)
    }

    func updateLanguage(_ language: AppLanguage) throws {
        var settings = try settingsStore.load()
        settings.language = language
        try saveSettings(settings)
    }

    @discardableResult
    func installLocalPlugin(from directory: URL) throws -> InstalledPlugin {
        let plugin = try localPluginInstaller.install(from: directory)
        try executionCoordinator.refreshMenuCache()
        return plugin
    }

    @discardableResult
    func installGitPlugin(from repositoryURL: String) throws -> InstalledPlugin {
        let plugin = try gitPluginInstaller.install(from: repositoryURL)
        try executionCoordinator.refreshMenuCache()
        return plugin
    }

    func trustPlugin(_ pluginID: String) throws {
        try pluginRepository.trust(pluginID: pluginID)
        try executionCoordinator.refreshMenuCache()
    }

    func removePlugin(_ pluginID: String) throws {
        try pluginRepository.remove(pluginID: pluginID)
        try executionCoordinator.refreshMenuCache()
    }

    func saveWorkflow(name: String, steps: [WorkflowDraftStep], existingID: String? = nil) throws {
        let sanitizedID = existingID ?? slug(for: name)
        let manifest = WorkflowManifest(
            id: sanitizedID,
            name: name,
            steps: steps.map { WorkflowStep(actionID: $0.actionID, input: $0.input) },
            failurePolicy: .stopOnFailure
        )
        try workflowRepository.save(manifest)
        try executionCoordinator.refreshMenuCache()
    }

    func removeWorkflow(_ workflow: WorkflowManifest) throws {
        try workflowRepository.remove(id: workflow.id)
        try executionCoordinator.refreshMenuCache()
    }

    func run(targetId: String, type: TargetType, selectedURLs: [URL]) throws -> ExecutionResult {
        let settings = try settingsStore.load()
        let monitoredRoot = settings.monitoredRoot(for: selectedURLs.first)
        return try executionCoordinator.execute(
            ExecutionRequest(
                targetId: targetId,
                targetType: type,
                selectedURLs: selectedURLs,
                invocationSource: .app,
                monitoredRootURL: monitoredRoot
            )
        )
    }

    func chooseDirectory() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        return panel.runModal() == .OK ? panel.url : nil
    }

    func openFinderExtensionsSettings() throws {
        guard systemSettingsLauncher.openFinderExtensionsSettings() else {
            throw NSError(
                domain: "ContextKitAppServices",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: L10n.string(
                        "app.settings.finderOpenFailed",
                        fallback: "Couldn't open macOS Finder extension settings."
                    ),
                ]
            )
        }
    }

    private func slug(for value: String) -> String {
        let normalized = value.lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return normalized.isEmpty ? "workflow-\(UUID().uuidString.lowercased())" : normalized
    }
}
