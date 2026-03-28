import ContextKitBuiltins
import ContextKitCore
import Foundation

final class ContextKitHelperListenerDelegate: NSObject, NSXPCListenerDelegate {
    private let service = ContextKitHelperService()

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: ContextKitFinderServiceProtocol.self)
        newConnection.exportedObject = service
        newConnection.resume()
        return true
    }
}

final class ContextKitHelperService: NSObject, ContextKitFinderServiceProtocol {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let settingsStore: SharedSettingsStore
    private let executionCoordinator: ExecutionCoordinator
    private let menuTreeBuilder = FinderMenuTreeBuilder()

    override init() {
        let directoryProvider = SharedDirectoryProvider()
        let settingsStore = SharedSettingsStore(directoryProvider: directoryProvider)
        let pluginRepository = PluginRepository(
            directoryProvider: directoryProvider,
            settingsStore: settingsStore
        )
        let workflowRepository = WorkflowRepository(directoryProvider: directoryProvider)
        let logStore = ExecutionLogStore(directoryProvider: directoryProvider)

        self.settingsStore = settingsStore
        self.executionCoordinator = ExecutionCoordinator(
            settingsStore: settingsStore,
            logStore: logStore,
            workflowRepository: workflowRepository,
            pluginRepository: pluginRepository,
            builtins: BuiltinActionRegistry.commands()
        )
        super.init()
    }

    func ping(withReply reply: @escaping (Bool) -> Void) {
        reply(true)
    }

    func observedRoots(withReply reply: @escaping (Data?, String?) -> Void) {
        do {
            let settings = try settingsStore.load()
            reply(
                try encoder.encode(
                    FinderObservedRootsResponse(paths: settings.monitoredRoots.map(\.path))
                ),
                nil
            )
        } catch {
            reply(nil, error.localizedDescription)
        }
    }

    func menu(for requestData: Data, withReply reply: @escaping (Data?, String?) -> Void) {
        do {
            let request = try decoder.decode(FinderSelectionRequest.self, from: requestData)
            let nodes = try menuNodes(for: request)
            reply(try encoder.encode(nodes), nil)
        } catch {
            reply(nil, error.localizedDescription)
        }
    }

    func execute(_ requestData: Data, withReply reply: @escaping (Data?, String?) -> Void) {
        do {
            let request = try decoder.decode(FinderExecutionRequest.self, from: requestData)
            let result = try executeRequest(request)
            reply(try encoder.encode(result), nil)
        } catch {
            reply(nil, error.localizedDescription)
        }
    }

    private func menuNodes(for request: FinderSelectionRequest) throws -> [FinderMenuNode] {
        let selectionURLs = request.effectiveSelectionURLs
        guard !selectionURLs.isEmpty else {
            return [FinderMenuNode(
                id: "finder.message.noSelection",
                title: L10n.string("finder.menu.noMatchingActions", fallback: "No matching actions"),
                kind: .message,
                enabled: false
            )]
        }

        let settings = try settingsStore.load()
        let monitoredRootURL = settings.monitoredRoot(for: selectionURLs.first)
        let snapshot = ContextSnapshot(selectedURLs: selectionURLs, monitoredRootURL: monitoredRootURL)
        let catalog = try executionCoordinator.catalog()
        let nodes = menuTreeBuilder.build(
            descriptors: catalog.menuDescriptors.filter(\.isEnabled),
            snapshot: snapshot
        )

        if nodes.isEmpty {
            return [FinderMenuNode(
                id: "finder.message.noSelection",
                title: L10n.string("finder.menu.noMatchingActions", fallback: "No matching actions"),
                kind: .message,
                enabled: false
            )]
        }

        return nodes
    }

    private func executeRequest(_ request: FinderExecutionRequest) throws -> FinderExecutionResult {
        let selectedURLs = request.effectiveSelectionURLs
        guard !selectedURLs.isEmpty else {
            return FinderExecutionResult(
                status: .skipped,
                message: "No item available."
            )
        }

        let settings = try settingsStore.load()
        let monitoredRootURL = settings.monitoredRoot(for: selectedURLs.first)
        let result = try executionCoordinator.execute(
            ExecutionRequest(
                targetId: request.targetID,
                targetType: request.targetType,
                selectedURLs: selectedURLs,
                invocationSource: .finder,
                monitoredRootURL: monitoredRootURL
            )
        )
        return FinderExecutionResult(result)
    }
}
