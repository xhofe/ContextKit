import Foundation
import Testing
@testable import ContextKitBuiltins

@Test
func relativePathCalculatorUsesMonitoredRoot() throws {
    let calculator = RelativePathCalculator()
    let root = URL(fileURLWithPath: "/Users/demo/workspace", isDirectory: true)
    let urls = [URL(fileURLWithPath: "/Users/demo/workspace/src/file.swift")]

    let paths = try calculator.relativePaths(for: urls, within: root)

    #expect(paths == ["src/file.swift"])
}
