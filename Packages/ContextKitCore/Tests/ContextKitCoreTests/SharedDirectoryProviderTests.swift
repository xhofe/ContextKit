import Foundation
import Testing
@testable import ContextKitCore

@Test
func sharedDirectoryProviderSkipsPreferredGroupWithoutEntitlement() throws {
    let expectedURL = URL(fileURLWithPath: "/tmp/contextkit-group", isDirectory: true)
    let provider = SharedDirectoryProvider(
        appGroupIdentifier: "6UKCRW5N6G.ci.nn.ContextKit",
        legacyAppGroupIdentifier: nil,
        containerURLProvider: { _ in expectedURL },
        hasApplicationGroupEntitlement: { _ in false }
    )

    #expect(try provider.preferredBaseURL() == nil)
}

@Test
func sharedDirectoryProviderUsesPreferredGroupWhenEntitled() throws {
    let fileManager = FileManager.default
    let expectedURL = fileManager.temporaryDirectory.appending(
        path: "SharedDirectoryProviderTests-\(UUID().uuidString)",
        directoryHint: .isDirectory
    )
    defer {
        try? fileManager.removeItem(at: expectedURL)
    }

    let provider = SharedDirectoryProvider(
        appGroupIdentifier: "6UKCRW5N6G.ci.nn.ContextKit",
        legacyAppGroupIdentifier: nil,
        fileManager: fileManager,
        containerURLProvider: { _ in expectedURL },
        hasApplicationGroupEntitlement: { _ in true }
    )

    #expect(try provider.preferredBaseURL() == expectedURL)
    #expect(fileManager.fileExists(atPath: expectedURL.path))
}
