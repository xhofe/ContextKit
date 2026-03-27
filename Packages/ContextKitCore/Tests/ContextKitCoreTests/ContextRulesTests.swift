import Foundation
import Testing
@testable import ContextKitCore

@Test
func contextRulesRejectDirectoriesWhenDisabled() {
    let snapshot = ContextSnapshot(
        selectedURLs: [URL(fileURLWithPath: "/tmp/demo", isDirectory: true)],
        monitoredRootURL: URL(fileURLWithPath: "/tmp", isDirectory: true)
    )
    let rules = ContextRules(allowFiles: true, allowDirectories: false)

    #expect(rules.matches(snapshot: snapshot) == false)
}
