import Foundation

public struct AnyActionCommand: Sendable {
    public var manifest: ActionManifest
    private let handler: @Sendable (ActionExecutionContext) throws -> ExecutionResult

    public init(
        manifest: ActionManifest,
        handler: @escaping @Sendable (ActionExecutionContext) throws -> ExecutionResult
    ) {
        self.manifest = manifest
        self.handler = handler
    }

    public func execute(_ context: ActionExecutionContext) throws -> ExecutionResult {
        try handler(context)
    }
}
