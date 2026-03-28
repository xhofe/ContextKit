import AppKit
import ContextKitPluginSDK
import Foundation

public final class ExecutionCoordinator: @unchecked Sendable {
    private let settingsStore: SharedSettingsStore
    private let logStore: ExecutionLogStore
    private let workflowRepository: WorkflowRepository
    private let pluginRepository: PluginRepository
    private let builtins: [String: AnyActionCommand]
    private let workflowExecutor: WorkflowExecutor
    private let processRunner: ProcessRunner

    public init(
        settingsStore: SharedSettingsStore = SharedSettingsStore(),
        logStore: ExecutionLogStore = ExecutionLogStore(),
        workflowRepository: WorkflowRepository = WorkflowRepository(),
        pluginRepository: PluginRepository = PluginRepository(),
        builtins: [AnyActionCommand],
        workflowExecutor: WorkflowExecutor = WorkflowExecutor(),
        processRunner: ProcessRunner = ProcessRunner()
    ) {
        self.settingsStore = settingsStore
        self.logStore = logStore
        self.workflowRepository = workflowRepository
        self.pluginRepository = pluginRepository
        self.builtins = Dictionary(uniqueKeysWithValues: builtins.map { ($0.manifest.id, $0) })
        self.workflowExecutor = workflowExecutor
        self.processRunner = processRunner
    }

    public func catalog() throws -> RuntimeCatalog {
        let settings = try settingsStore.load()
        let plugins = try pluginRepository.installedPlugins()
        let actionManifests = builtins.values.map(\.manifest) + plugins.map(\.package.manifest)
        let orderedActions = sort(manifests: actionManifests, settings: settings)
        let workflows = try workflowRepository.list()
        let menuLayout = MenuLayoutResolver.resolve(
            actions: orderedActions,
            workflows: workflows,
            settings: settings
        )
        let menuDescriptors = MenuLayoutResolver.descriptors(
            from: menuLayout,
            actions: orderedActions,
            workflows: workflows,
            settings: settings
        )

        return RuntimeCatalog(
            actions: orderedActions,
            workflows: workflows,
            menuDescriptors: menuDescriptors
        )
    }

    public func refreshMenuCache() throws {
        _ = try catalog()
    }

    @discardableResult
    public func execute(_ request: ExecutionRequest) throws -> ExecutionResult {
        let settings = try settingsStore.load()
        let monitoredRootURL = request.monitoredRootURL ?? settings.monitoredRoot(for: request.selectedURLs.first)

        let result: ExecutionResult
        switch request.targetType {
        case .action:
            result = try runAction(request, settings: settings, monitoredRootURL: monitoredRootURL)
        case .workflow:
            result = try runWorkflow(request, settings: settings, monitoredRootURL: monitoredRootURL)
        }

        try logStore.append(
            ExecutionLogEntry(
                request: request,
                result: result
            )
        )
        return result
    }

    private func runWorkflow(
        _ request: ExecutionRequest,
        settings: AppSettings,
        monitoredRootURL: URL?
    ) throws -> ExecutionResult {
        let workflow = try workflowRepository.load(id: request.targetId)
        return try workflowExecutor.execute(workflow: workflow, initialRequest: request) { [weak self] stepRequest in
            guard let self else {
                throw ExecutionCoordinatorError.unknownWorkflow(request.targetId)
            }
            return try self.runAction(stepRequest, settings: settings, monitoredRootURL: monitoredRootURL)
        }
    }

    private func runAction(
        _ request: ExecutionRequest,
        settings: AppSettings,
        monitoredRootURL: URL?
    ) throws -> ExecutionResult {
        if let builtin = builtins[request.targetId] {
            let context = ActionExecutionContext(
                request: request,
                settings: settings,
                monitoredRootURL: monitoredRootURL,
                processRunner: processRunner
            )
            return try builtin.execute(context)
        }

        guard let plugin = try pluginRepository.installedPlugin(id: request.targetId) else {
            throw ExecutionCoordinatorError.unknownAction(request.targetId)
        }

        guard plugin.isTrusted else {
            throw ExecutionCoordinatorError.untrustedPlugin(request.targetId)
        }

        return try executePlugin(plugin, request: request)
    }

    private func executePlugin(_ plugin: InstalledPlugin, request: ExecutionRequest) throws -> ExecutionResult {
        guard let entrypointURL = plugin.package.entrypointURL else {
            throw ExecutionCoordinatorError.invalidPluginEntrypoint(plugin.package.manifest.id)
        }

        let arguments = resolveArguments(for: plugin.package.manifest.argsTemplate, request: request)
        var environment = request.environmentOverrides
        let selectedURLData = try JSONEncoder().encode(request.selectedURLs.map(\.path))
        environment[PluginEnvironment.requestID] = UUID().uuidString
        environment[PluginEnvironment.selectedURLsJSON] = String(decoding: selectedURLData, as: UTF8.self)
        environment[PluginEnvironment.invocationSource] = request.invocationSource.rawValue
        environment[PluginEnvironment.monitoredRootPath] = request.monitoredRootURL?.path ?? ""

        let output = try processRunner.run(
            executableURL: entrypointURL,
            arguments: arguments,
            environment: environment,
            currentDirectoryURL: plugin.package.rootURL
        )

        guard output.terminationStatus == 0 else {
            throw ExecutionCoordinatorError.processFailed(output.standardError.isEmpty ? output.standardOutput : output.standardError)
        }

        let result = try decodePluginOutput(
            output: output.standardOutput,
            fallbackMessage: plugin.package.manifest.name
        )

        if let clipboardText = result.clipboardText {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(clipboardText, forType: .string)
        }

        return result
    }

    private func decodePluginOutput(output: String, fallbackMessage: String) throws -> ExecutionResult {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ExecutionResult(status: .success, message: fallbackMessage)
        }

        if let data = trimmed.data(using: .utf8),
           let pluginOutput = try? JSONDecoder().decode(PluginOutput.self, from: data) {
            return ExecutionResult(
                status: .success,
                message: pluginOutput.message ?? fallbackMessage,
                producedURLs: pluginOutput.producedPaths.map(URL.init(fileURLWithPath:)),
                clipboardText: pluginOutput.clipboardText,
                structuredPayload: pluginOutput.structuredPayload,
                logs: pluginOutput.logLines.map { ExecutionLogLine(message: $0) }
            )
        }

        return ExecutionResult(
            status: .success,
            message: trimmed,
            clipboardText: trimmed
        )
    }

    private func resolveArguments(for template: [String], request: ExecutionRequest) -> [String] {
        template.flatMap { value in
            switch value {
            case "{files}":
                return request.selectedURLs.map(\.path)
            case "{firstFile}":
                return request.selectedURLs.first.map { [$0.path] } ?? []
            case "{monitoredRoot}":
                return request.monitoredRootURL.map { [$0.path] } ?? []
            default:
                return [value]
            }
        }
    }

    private func sort(manifests: [ActionManifest], settings: AppSettings) -> [ActionManifest] {
        let orderMap = Dictionary(uniqueKeysWithValues: settings.orderedActionIDs.enumerated().map { ($1, $0) })
        return manifests.sorted { lhs, rhs in
            switch (orderMap[lhs.id], orderMap[rhs.id]) {
            case let (left?, right?):
                return left < right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                if lhs.category == rhs.category {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhs.category.rawValue < rhs.category.rawValue
            }
        }
    }
}
