import Foundation

public final class AgentInbox: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider()) {
        self.directoryProvider = directoryProvider
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func enqueue(_ request: ExecutionRequest) throws -> ExecutionRequestEnvelope {
        let envelope = ExecutionRequestEnvelope(request: request)
        let url = try requestURL(for: envelope.id)
        let data = try encoder.encode(envelope)
        try data.write(to: url, options: .atomic)
        DistributedNotificationCenter.default().post(name: IPCNotification.requestQueued, object: nil)
        return envelope
    }

    public func pendingRequests() throws -> [ExecutionRequestEnvelope] {
        let directory = try directoryProvider.requestDirectoryURL()
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        return try urls
            .filter { $0.pathExtension == "json" }
            .map { try decoder.decode(ExecutionRequestEnvelope.self, from: Data(contentsOf: $0)) }
            .sorted(by: { $0.createdAt < $1.createdAt })
    }

    public func writeResponse(_ response: ExecutionResponseEnvelope) throws {
        let url = try responseURL(for: response.requestID)
        let data = try encoder.encode(response)
        try data.write(to: url, options: .atomic)
    }

    public func waitForResponse(requestID: UUID, timeout: TimeInterval = 5.0) throws -> ExecutionResponseEnvelope? {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let response = try loadResponse(requestID: requestID) {
                return response
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return nil
    }

    public func loadResponse(requestID: UUID) throws -> ExecutionResponseEnvelope? {
        let url = try responseURL(for: requestID)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return try decoder.decode(ExecutionResponseEnvelope.self, from: Data(contentsOf: url))
    }

    public func removeRequest(id: UUID) throws {
        let url = try requestURL(for: id)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try FileManager.default.removeItem(at: url)
    }

    public func removeResponse(requestID: UUID) throws {
        let url = try responseURL(for: requestID)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try FileManager.default.removeItem(at: url)
    }

    private func requestURL(for id: UUID) throws -> URL {
        try directoryProvider.requestDirectoryURL().appending(path: "\(id.uuidString).json")
    }

    private func responseURL(for id: UUID) throws -> URL {
        try directoryProvider.responseDirectoryURL().appending(path: "\(id.uuidString).json")
    }
}
