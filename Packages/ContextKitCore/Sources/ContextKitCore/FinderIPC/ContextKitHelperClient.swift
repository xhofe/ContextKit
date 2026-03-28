import Foundation

public enum ContextKitHelperClientError: LocalizedError {
    case serviceUnavailable(String)
    case invalidResponse
    case timeout

    public var errorDescription: String? {
        switch self {
        case let .serviceUnavailable(message):
            return message.isEmpty ? "ContextKit helper is unavailable." : message
        case .invalidResponse:
            return "ContextKit helper returned an invalid response."
        case .timeout:
            return "ContextKit helper timed out."
        }
    }
}

public final class ContextKitHelperClient: @unchecked Sendable {
    private let timeout: TimeInterval
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public init(timeout: TimeInterval = 5.0) {
        self.timeout = timeout
    }

    public func ping() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var isAlive = false
        var receivedReply = false

        let connection = makeConnection()
        defer { connection.invalidate() }

        guard let proxy = connection.remoteObjectProxyWithErrorHandler({ _ in
            semaphore.signal()
        }) as? ContextKitFinderServiceProtocol else {
            return false
        }

        proxy.ping { result in
            isAlive = result
            receivedReply = true
            semaphore.signal()
        }

        guard semaphore.wait(timeout: .now() + timeout) == .success else {
            return false
        }

        return receivedReply && isAlive
    }

    public func observedRoots() throws -> [String] {
        let response: FinderObservedRootsResponse = try performRequest { proxy, reply in
            proxy.observedRoots(withReply: reply)
        }
        return response.paths
    }

    public func menu(for request: FinderSelectionRequest) throws -> [FinderMenuNode] {
        let data = try encoder.encode(request)
        return try performRequest { proxy, reply in
            proxy.menu(for: data, withReply: reply)
        }
    }

    public func execute(_ request: FinderExecutionRequest) throws -> FinderExecutionResult {
        let data = try encoder.encode(request)
        return try performRequest { proxy, reply in
            proxy.execute(data, withReply: reply)
        }
    }

    private func performRequest<T: Decodable>(
        _ invoke: (ContextKitFinderServiceProtocol, @escaping (Data?, String?) -> Void) -> Void
    ) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data?
        var responseError: Error?

        let connection = makeConnection()
        defer { connection.invalidate() }

        guard let proxy = connection.remoteObjectProxyWithErrorHandler({ error in
            responseError = error
            semaphore.signal()
        }) as? ContextKitFinderServiceProtocol else {
            throw ContextKitHelperClientError.serviceUnavailable("Unable to create helper connection.")
        }

        invoke(proxy) { data, message in
            responseData = data
            if let message {
                responseError = ContextKitHelperClientError.serviceUnavailable(message)
            }
            semaphore.signal()
        }

        guard semaphore.wait(timeout: .now() + timeout) == .success else {
            throw ContextKitHelperClientError.timeout
        }

        if let responseError {
            throw responseError
        }

        guard let responseData else {
            throw ContextKitHelperClientError.invalidResponse
        }

        return try decoder.decode(T.self, from: responseData)
    }

    private func makeConnection() -> NSXPCConnection {
        let interface = NSXPCInterface(with: ContextKitFinderServiceProtocol.self)
        let connection = NSXPCConnection(
            machServiceName: ContextKitHelperConstants.machServiceName,
            options: []
        )
        connection.remoteObjectInterface = interface
        connection.resume()
        return connection
    }
}
