import Foundation

public struct WorkflowManifestLoader: Sendable {
    private let decoder = JSONDecoder()

    public init() {}

    public func load(from url: URL) throws -> WorkflowManifest {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ManifestError.missingManifest(url)
        }

        do {
            let data = try Data(contentsOf: url)
            let manifest = try decoder.decode(WorkflowManifest.self, from: data)
            guard !manifest.steps.isEmpty else {
                throw ManifestError.invalidWorkflow(manifest.id)
            }
            return manifest
        } catch {
            if let manifestError = error as? ManifestError {
                throw manifestError
            }
            throw ManifestError.invalidManifest(url, error.localizedDescription)
        }
    }
}
