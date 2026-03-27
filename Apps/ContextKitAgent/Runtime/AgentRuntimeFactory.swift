import ContextKitBuiltins
import ContextKitCore
import Foundation

enum AgentRuntimeFactory {
    static func makeCoordinator() -> ExecutionCoordinator {
        let settingsStore = SharedSettingsStore()
        let pluginRepository = PluginRepository(settingsStore: settingsStore)
        return ExecutionCoordinator(
            settingsStore: settingsStore,
            workflowRepository: WorkflowRepository(),
            pluginRepository: pluginRepository,
            builtins: BuiltinActionRegistry.commands()
        )
    }
}
