import Foundation

final class LocalizationPreferences: @unchecked Sendable {
    static let shared = LocalizationPreferences()

    private let settingsStore: SharedSettingsStore
    private let directoryProvider: SharedDirectoryProvider
    private let fileManager: FileManager
    private let lock = NSLock()

    private var cachedLanguage: AppLanguage = .system
    private var cachedSignature = SettingsSignature()

    init(
        settingsStore: SharedSettingsStore = SharedSettingsStore(),
        directoryProvider: SharedDirectoryProvider = SharedDirectoryProvider(),
        fileManager: FileManager = .default
    ) {
        self.settingsStore = settingsStore
        self.directoryProvider = directoryProvider
        self.fileManager = fileManager
    }

    func currentLanguage() -> AppLanguage {
        let signature = settingsSignature()

        lock.lock()
        if cachedSignature == signature {
            let language = cachedLanguage
            lock.unlock()
            return language
        }
        lock.unlock()

        let language = (try? settingsStore.load().language) ?? .system

        lock.lock()
        cachedLanguage = language
        cachedSignature = signature
        lock.unlock()

        return language
    }

    func invalidate() {
        lock.lock()
        cachedSignature = SettingsSignature()
        lock.unlock()
    }

    private func settingsSignature() -> SettingsSignature {
        guard let url = try? directoryProvider.settingsURL(),
              fileManager.fileExists(atPath: url.path) else {
            return SettingsSignature()
        }

        let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
        return SettingsSignature(
            exists: true,
            contentModificationDate: values?.contentModificationDate,
            fileSize: values?.fileSize
        )
    }
}

private struct SettingsSignature: Equatable {
    var exists = false
    var contentModificationDate: Date?
    var fileSize: Int?
}
