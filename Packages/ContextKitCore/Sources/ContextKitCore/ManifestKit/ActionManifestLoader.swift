import Foundation

public struct ActionManifestLoader: Sendable {
    private let decoder = JSONDecoder()

    public init() {}

    public func load(from url: URL) throws -> ActionManifest {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ManifestError.missingManifest(url)
        }

        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(ActionManifest.self, from: data)
        } catch {
            throw ManifestError.invalidManifest(url, error.localizedDescription)
        }
    }
}
