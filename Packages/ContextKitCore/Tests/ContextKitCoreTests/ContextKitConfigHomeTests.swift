import Foundation
import Testing
@testable import ContextKitCore

@Test
func contextKitConfigHomeLocatorCreatesDotConfigContextKitDirectory() throws {
    let fileManager = FileManager.default
    let fakeHome = fileManager.temporaryDirectory.appending(
        path: "ContextKitConfigHomeTests-\(UUID().uuidString)",
        directoryHint: .isDirectory
    )
    defer {
        try? fileManager.removeItem(at: fakeHome)
    }

    let locator = ContextKitConfigHomeLocator(
        fileManager: fileManager,
        homeDirectoryURLProvider: { fakeHome }
    )

    let resolvedURL = try locator.resolve()

    #expect(resolvedURL.path == fakeHome.appending(path: ".config/ContextKit").path)
    #expect(fileManager.fileExists(atPath: resolvedURL.path))
}

@Test
func sharedDirectoryProviderUsesLowercaseConfigStructure() throws {
    let fileManager = FileManager.default
    let fakeHome = fileManager.temporaryDirectory.appending(
        path: "SharedDirectoryProviderTests-\(UUID().uuidString)",
        directoryHint: .isDirectory
    )
    defer {
        try? fileManager.removeItem(at: fakeHome)
    }

    let provider = SharedDirectoryProvider(
        configHomeLocator: ContextKitConfigHomeLocator(
            fileManager: fileManager,
            homeDirectoryURLProvider: { fakeHome }
        ),
        fileManager: fileManager
    )

    #expect(try provider.pluginsDirectoryURL().path.hasSuffix("/.config/ContextKit/plugins"))
    #expect(try provider.workflowsDirectoryURL().path.hasSuffix("/.config/ContextKit/workflows"))
    #expect(try provider.logsURL().path.hasSuffix("/.config/ContextKit/logs/execution-log.json"))
}
