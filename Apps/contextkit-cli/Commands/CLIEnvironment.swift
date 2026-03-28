import ContextKitBuiltins
import ContextKitCore
import Foundation

struct CLIEnvironment {
    let settingsStore: SharedSettingsStore
    let pluginRepository: PluginRepository
    let workflowRepository: WorkflowRepository
    let logStore: ExecutionLogStore
    let localPluginInstaller: LocalPluginInstaller
    let gitPluginInstaller: GitPluginInstaller
    let executionCoordinator: ExecutionCoordinator

    init() {
        let localDirectoryProvider = SharedDirectoryProvider.appSupport()
        let settingsStore = SharedSettingsStore(directoryProvider: localDirectoryProvider)
        let pluginRepository = PluginRepository(
            directoryProvider: localDirectoryProvider,
            settingsStore: settingsStore
        )
        let workflowRepository = WorkflowRepository(directoryProvider: localDirectoryProvider)
        let logStore = ExecutionLogStore(directoryProvider: localDirectoryProvider)

        self.settingsStore = settingsStore
        self.pluginRepository = pluginRepository
        self.workflowRepository = workflowRepository
        self.logStore = logStore
        self.localPluginInstaller = LocalPluginInstaller(pluginRepository: pluginRepository)
        self.gitPluginInstaller = GitPluginInstaller(pluginRepository: pluginRepository)
        self.executionCoordinator = ExecutionCoordinator(
            settingsStore: settingsStore,
            menuDescriptorCache: MenuDescriptorCache(directoryProvider: localDirectoryProvider),
            logStore: logStore,
            workflowRepository: workflowRepository,
            pluginRepository: pluginRepository,
            builtins: BuiltinActionRegistry.commands()
        )
    }
}
