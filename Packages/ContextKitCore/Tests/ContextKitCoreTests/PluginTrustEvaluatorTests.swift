import Testing
@testable import ContextKitCore

@Test
func pluginTrustEvaluatorDetectsNewCapabilities() {
    let evaluator = PluginTrustEvaluator()
    let manifest = ActionManifest(
        id: "plugin.demo",
        name: "Demo",
        category: .custom,
        kind: .plugin,
        contextRules: ContextRules(),
        capabilities: [.clipboard, .subprocess]
    )
    let grant = TrustedPluginGrant(
        pluginID: "plugin.demo",
        capabilities: [.clipboard],
        sourceDescription: "Local"
    )

    let diff = evaluator.diff(for: manifest, grant: grant)

    #expect(diff.added == [.subprocess])
    #expect(diff.removed.isEmpty)
}
