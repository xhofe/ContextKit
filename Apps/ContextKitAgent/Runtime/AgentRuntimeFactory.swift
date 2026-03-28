import ContextKitBuiltins
import ContextKitCore
import Foundation

enum AgentRuntimeFactory {
    static func makeCoordinator() -> ExecutionCoordinator {
        let localDirectoryProvider = SharedDirectoryProvider.appSupport()
        let settingsStore = SharedSettingsStore(directoryProvider: localDirectoryProvider)
        let pluginRepository = PluginRepository(
            directoryProvider: localDirectoryProvider,
            settingsStore: settingsStore
        )
        return ExecutionCoordinator(
            settingsStore: settingsStore,
            menuDescriptorCache: MenuDescriptorCache(directoryProvider: localDirectoryProvider),
            logStore: ExecutionLogStore(directoryProvider: localDirectoryProvider),
            workflowRepository: WorkflowRepository(directoryProvider: localDirectoryProvider),
            pluginRepository: pluginRepository,
            builtins: BuiltinActionRegistry.commands()
        )
    }
}
