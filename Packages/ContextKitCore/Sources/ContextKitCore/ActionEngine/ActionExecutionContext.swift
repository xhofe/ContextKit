import Foundation

public struct ActionExecutionContext: Sendable {
    public var request: ExecutionRequest
    public var settings: AppSettings
    public var monitoredRootURL: URL?
    public var processRunner: ProcessRunner

    public init(
        request: ExecutionRequest,
        settings: AppSettings,
        monitoredRootURL: URL?,
        processRunner: ProcessRunner = ProcessRunner()
    ) {
        self.request = request
        self.settings = settings
        self.monitoredRootURL = monitoredRootURL
        self.processRunner = processRunner
    }
}
