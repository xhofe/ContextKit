import ContextKitCore
import Foundation

struct FinderBridgeSynchronizer {
    private let localSettingsStore: SharedSettingsStore
    private let localMenuDescriptorCache: MenuDescriptorCache
    private let bridgeSettingsStore: SharedSettingsStore
    private let bridgeMenuDescriptorCache: MenuDescriptorCache

    init(
        localDirectoryProvider: SharedDirectoryProvider = .appSupport(),
        bridgeDirectoryProvider: SharedDirectoryProvider = .appGroupBridge()
    ) {
        self.localSettingsStore = SharedSettingsStore(directoryProvider: localDirectoryProvider)
        self.localMenuDescriptorCache = MenuDescriptorCache(directoryProvider: localDirectoryProvider)
        self.bridgeSettingsStore = SharedSettingsStore(directoryProvider: bridgeDirectoryProvider)
        self.bridgeMenuDescriptorCache = MenuDescriptorCache(directoryProvider: bridgeDirectoryProvider)
    }

    func sync() throws {
        let settings = try localSettingsStore.load()
        let descriptors = try localMenuDescriptorCache.load()
        try bridgeSettingsStore.save(settings)
        try bridgeMenuDescriptorCache.save(descriptors)
    }
}
