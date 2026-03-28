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

@Test
func menuLayoutResolverMigratesLegacyEditorActionIntoEditorGroup() {
    let actions = [
        ActionManifest(
            id: BuiltinActionIdentifier.openInEditorActionID(for: AppLauncher.editorDefault),
            name: AppLauncher.editorDefault.name,
            category: .open,
            kind: .builtin,
            contextRules: ContextRules(),
            capabilities: [.openApp]
        ),
        ActionManifest(
            id: BuiltinActionIdentifier.openInEditorActionID(for: AppLauncher.editorCursor),
            name: AppLauncher.editorCursor.name,
            category: .open,
            kind: .builtin,
            contextRules: ContextRules(),
            capabilities: [.openApp]
        ),
    ]

    let settings = AppSettings(
        menuLayout: [
            .group(
                id: "group.category.open",
                title: "Open",
                children: [
                    .action("builtin.open-editor"),
                ]
            ),
        ]
    )

    let resolved = MenuLayoutResolver.resolve(actions: actions, workflows: [], settings: settings)

    #expect(resolved.first?.children.contains(where: { $0.id == "group.open-editors" }) == true)
}
