import Foundation
import Testing
@testable import ContextKitCore

@Test
func finderMenuTreeBuilderReturnsNestedVisibleNodes() {
    let builder = FinderMenuTreeBuilder()
    let selectionURL = URL(fileURLWithPath: "/tmp/workspace/file.txt")
    let snapshot = ContextSnapshot(
        selectedURLs: [selectionURL],
        monitoredRootURL: URL(fileURLWithPath: "/tmp/workspace", isDirectory: true)
    )
    let descriptors = [
        MenuDescriptor(
            id: "group.open",
            title: "Open",
            kind: .group,
            category: .open,
            targetType: nil,
            contextRules: ContextRules(),
            isEnabled: true,
            sortOrder: 0
        ),
        MenuDescriptor(
            id: "action.editor",
            title: "VS Code",
            kind: .action,
            category: .open,
            targetType: .action,
            contextRules: ContextRules(),
            isEnabled: true,
            sortOrder: 0,
            parentID: "group.open"
        ),
    ]

    let nodes = builder.build(descriptors: descriptors, snapshot: snapshot)

    #expect(nodes.count == 1)
    #expect(nodes.first?.kind == .group)
    #expect(nodes.first?.children.first?.id == "action.editor")
    #expect(nodes.first?.children.first?.targetType == .action)
}

@Test
func finderMenuTreeBuilderFiltersNonMatchingLeaves() {
    let builder = FinderMenuTreeBuilder()
    let selectionURL = URL(fileURLWithPath: "/tmp/workspace/file.txt")
    let snapshot = ContextSnapshot(
        selectedURLs: [selectionURL],
        monitoredRootURL: URL(fileURLWithPath: "/tmp/workspace", isDirectory: true)
    )
    let descriptors = [
        MenuDescriptor(
            id: "workflow.directories",
            title: "Directories Only",
            kind: .workflow,
            category: .custom,
            targetType: .workflow,
            contextRules: ContextRules(allowFiles: false, allowDirectories: true),
            isEnabled: true,
            sortOrder: 0
        ),
    ]

    let nodes = builder.build(descriptors: descriptors, snapshot: snapshot)

    #expect(nodes.isEmpty)
}
