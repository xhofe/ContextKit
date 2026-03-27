import Foundation

public final class AgentInbox: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager: FileManager

    public init(
        directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider(),
        fileManager: FileManager = .default
    ) {
        self.directoryProvider = directoryProvider
        self.fileManager = fileManager
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func enqueue(_ request: ExecutionRequest) throws -> ExecutionRequestEnvelope {
        let envelope = ExecutionRequestEnvelope(request: request)
        let data = try encoder.encode(envelope)
        try write(data, to: requestURLs(for: envelope.id))
        DistributedNotificationCenter.default().post(name: IPCNotification.requestQueued, object: nil)
        return envelope
    }

    public func pendingRequests() throws -> [ExecutionRequestEnvelope] {
        var envelopesByID: [UUID: ExecutionRequestEnvelope] = [:]

        for directory in try requestDirectoryURLs() {
            let urls = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for url in urls where url.pathExtension == "json" {
                let envelope = try decoder.decode(ExecutionRequestEnvelope.self, from: Data(contentsOf: url))
                if let existing = envelopesByID[envelope.id], existing.createdAt <= envelope.createdAt {
                    continue
                }
                envelopesByID[envelope.id] = envelope
            }
        }

        return envelopesByID.values.sorted(by: { $0.createdAt < $1.createdAt })
    }

    public func writeResponse(_ response: ExecutionResponseEnvelope) throws {
        let data = try encoder.encode(response)
        try write(data, to: responseURLs(for: response.requestID))
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
        for url in try responseURLs(for: requestID) where fileManager.fileExists(atPath: url.path) {
            return try decoder.decode(ExecutionResponseEnvelope.self, from: Data(contentsOf: url))
        }
        return nil
    }

    public func removeRequest(id: UUID) throws {
        for url in try requestURLs(for: id) where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    public func removeResponse(requestID: UUID) throws {
        for url in try responseURLs(for: requestID) where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    private func requestURLs(for id: UUID) throws -> [URL] {
        try requestDirectoryURLs().map { $0.appending(path: "\(id.uuidString).json") }
    }

    private func responseURLs(for id: UUID) throws -> [URL] {
        try responseDirectoryURLs().map { $0.appending(path: "\(id.uuidString).json") }
    }

    private func requestDirectoryURLs() throws -> [URL] {
        try accessibleDirectoryURLs(named: "Requests")
    }

    private func responseDirectoryURLs() throws -> [URL] {
        try accessibleDirectoryURLs(named: "Responses")
    }

    private func accessibleDirectoryURLs(named directoryName: String) throws -> [URL] {
        var accessibleURLs: [URL] = []
        var lastError: Error?

        for baseURL in try directoryProvider.ipcBaseURLs() {
            let directoryURL = baseURL.appending(path: directoryName, directoryHint: .isDirectory)

            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                accessibleURLs.append(directoryURL)
            } catch {
                lastError = error
            }
        }

        if !accessibleURLs.isEmpty {
            return accessibleURLs
        }

        throw lastError ?? CocoaError(.fileWriteUnknown)
    }

    private func write(_ data: Data, to urls: [URL]) throws {
        var lastError: Error?
        var didWrite = false

        for url in urls {
            do {
                try data.write(to: url, options: .atomic)
                didWrite = true
            } catch {
                lastError = error
            }
        }

        if didWrite {
            return
        }

        throw lastError ?? CocoaError(.fileWriteUnknown)
    }
}
