import Foundation
import Testing
@testable import ContextKitPluginSDK

@Test
func pluginOutputRoundTripsThroughJSON() throws {
    let output = PluginOutput(
        message: "Done",
        clipboardText: "copied",
        producedPaths: ["/tmp/output.txt"],
        structuredPayload: ["kind": "demo"],
        logLines: ["step 1"]
    )

    let data = try JSONEncoder().encode(output)
    let decoded = try JSONDecoder().decode(PluginOutput.self, from: data)

    #expect(decoded == output)
}
