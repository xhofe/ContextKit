import Foundation

public final class SharedSettingsStore: @unchecked Sendable {
    private let directoryProvider: SharedDirectoryProvider
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider()) {
        self.directoryProvider = directoryProvider
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func load() throws -> AppSettings {
        let url = try directoryProvider.settingsURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            let defaults = AppSettings()
            try save(defaults)
            return defaults
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(AppSettings.self, from: data)
    }

    public func save(_ settings: AppSettings) throws {
        let url = try directoryProvider.settingsURL()
        let data = try encoder.encode(settings)
        try data.write(to: url, options: .atomic)
    }
}
