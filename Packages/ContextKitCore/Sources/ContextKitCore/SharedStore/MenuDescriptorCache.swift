import Foundation

public final class MenuDescriptorCache: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider()) {
        self.directoryProvider = directoryProvider
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func load() throws -> [MenuDescriptor] {
        let url = try directoryProvider.menuDescriptorURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode([MenuDescriptor].self, from: data)
    }

    public func save(_ descriptors: [MenuDescriptor]) throws {
        let url = try directoryProvider.menuDescriptorURL()
        let data = try encoder.encode(descriptors)
        try data.write(to: url, options: .atomic)
    }
}
