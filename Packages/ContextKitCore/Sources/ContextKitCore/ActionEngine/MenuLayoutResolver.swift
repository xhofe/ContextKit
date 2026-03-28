import Foundation

public enum MenuLayoutResolver {
    public static func resolve(
        actions: [ActionManifest],
        workflows: [WorkflowManifest],
        settings: AppSettings
    ) -> [MenuLayoutItem] {
        if settings.menuLayout.isEmpty {
            return defaultLayout(actions: actions, workflows: workflows)
        }

        let actionIDs = Set(actions.map(\.id))
        let workflowIDs = Set(workflows.map(\.id))
        let sanitized = sanitize(
            items: settings.menuLayout,
            actionIDs: actionIDs,
            workflowIDs: workflowIDs
        )

        let placedActionIDs = Set(flatten(items: sanitized, matching: .action))
        let placedWorkflowIDs = Set(flatten(items: sanitized, matching: .workflow))

        let missingActions = actions
            .filter { !placedActionIDs.contains($0.id) }
            .map { MenuLayoutItem.action($0.id) }
        let missingWorkflows = workflows
            .filter { !placedWorkflowIDs.contains($0.id) }
            .map { MenuLayoutItem.workflow($0.id) }

        return sanitized + missingActions + missingWorkflows
    }

    public static func descriptors(
        from layout: [MenuLayoutItem],
        actions: [ActionManifest],
        workflows: [WorkflowManifest],
        settings: AppSettings
    ) -> [MenuDescriptor] {
        let actionMap = Dictionary(uniqueKeysWithValues: actions.map { ($0.id, $0) })
        let workflowMap = Dictionary(uniqueKeysWithValues: workflows.map { ($0.id, $0) })

        var descriptors: [MenuDescriptor] = []
        appendDescriptors(
            from: layout,
            parentID: nil,
            actionMap: actionMap,
            workflowMap: workflowMap,
            settings: settings,
            into: &descriptors
        )
        return descriptors
    }

    public static func defaultLayout(
        actions: [ActionManifest],
        workflows: [WorkflowManifest]
    ) -> [MenuLayoutItem] {
        let terminalActionIDs = Set(
            AppLauncher.knownTerminalLaunchers.map(BuiltinActionIdentifier.openInTerminalActionID(for:))
        )

        let orderedActions = actions.sorted { lhs, rhs in
            if lhs.category == rhs.category {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.category.rawValue < rhs.category.rawValue
        }

        let openChildren = orderedActions
            .filter { $0.category == .open && !terminalActionIDs.contains($0.id) }
            .map { MenuLayoutItem.action($0.id) }
        let terminalChildren = orderedActions
            .filter { terminalActionIDs.contains($0.id) }
            .map { MenuLayoutItem.action($0.id) }
        let toolChildren = orderedActions
            .filter { $0.category == .tools }
            .map { MenuLayoutItem.action($0.id) }
        let intelligentChildren = orderedActions
            .filter { $0.category == .intelligent }
            .map { MenuLayoutItem.action($0.id) } + workflows.map { MenuLayoutItem.workflow($0.id) }
        let customChildren = orderedActions
            .filter { $0.category == .custom }
            .map { MenuLayoutItem.action($0.id) }

        var rootItems: [MenuLayoutItem] = []

        if !openChildren.isEmpty || !terminalChildren.isEmpty {
            var children = openChildren
            if !terminalChildren.isEmpty {
                children.insert(
                    .group(
                        id: "group.open-terminals",
                        title: L10n.string("menu.group.openInTerminal", fallback: "Open in Terminal"),
                        children: terminalChildren
                    ),
                    at: 0
                )
            }

            rootItems.append(
                .group(
                    id: "group.category.open",
                    title: ActionCategory.open.displayName,
                    children: children
                )
            )
        }

        if !toolChildren.isEmpty {
            rootItems.append(
                .group(
                    id: "group.category.tools",
                    title: ActionCategory.tools.displayName,
                    children: toolChildren
                )
            )
        }

        if !intelligentChildren.isEmpty {
            rootItems.append(
                .group(
                    id: "group.category.intelligent",
                    title: ActionCategory.intelligent.displayName,
                    children: intelligentChildren
                )
            )
        }

        if !customChildren.isEmpty {
            rootItems.append(
                .group(
                    id: "group.category.custom",
                    title: ActionCategory.custom.displayName,
                    children: customChildren
                )
            )
        }

        return rootItems
    }

    private static func sanitize(
        items: [MenuLayoutItem],
        actionIDs: Set<String>,
        workflowIDs: Set<String>
    ) -> [MenuLayoutItem] {
        items.compactMap { item in
            switch item.kind {
            case .group:
                var group = item
                group.children = sanitize(items: item.children, actionIDs: actionIDs, workflowIDs: workflowIDs)
                return group
            case .action:
                return actionIDs.contains(item.id) ? item : nil
            case .workflow:
                return workflowIDs.contains(item.id) ? item : nil
            }
        }
    }

    private static func flatten(items: [MenuLayoutItem], matching kind: MenuLayoutItem.Kind) -> [String] {
        items.flatMap { item in
            if item.kind == kind {
                return [item.id]
            }
            return flatten(items: item.children, matching: kind)
        }
    }

    private static func appendDescriptors(
        from items: [MenuLayoutItem],
        parentID: String?,
        actionMap: [String: ActionManifest],
        workflowMap: [String: WorkflowManifest],
        settings: AppSettings,
        into descriptors: inout [MenuDescriptor]
    ) {
        for (index, item) in items.enumerated() {
            switch item.kind {
            case .group:
                let trimmedTitle = item.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !trimmedTitle.isEmpty else {
                    continue
                }

                descriptors.append(
                    MenuDescriptor(
                        id: item.id,
                        title: trimmedTitle,
                        kind: .group,
                        category: .custom,
                        targetType: nil,
                        contextRules: ContextRules(),
                        isEnabled: true,
                        sortOrder: index,
                        parentID: parentID
                    )
                )

                appendDescriptors(
                    from: item.children,
                    parentID: item.id,
                    actionMap: actionMap,
                    workflowMap: workflowMap,
                    settings: settings,
                    into: &descriptors
                )
            case .action:
                guard let manifest = actionMap[item.id] else {
                    continue
                }

                descriptors.append(
                    MenuDescriptor(
                        id: manifest.id,
                        title: manifest.name,
                        kind: .action,
                        category: manifest.category,
                        targetType: .action,
                        contextRules: manifest.contextRules,
                        isEnabled: isActionVisible(manifest.id, settings: settings),
                        sortOrder: index,
                        parentID: parentID
                    )
                )
            case .workflow:
                guard let workflow = workflowMap[item.id] else {
                    continue
                }

                descriptors.append(
                    MenuDescriptor(
                        id: workflow.id,
                        title: workflow.name,
                        kind: .workflow,
                        category: .intelligent,
                        targetType: .workflow,
                        contextRules: ContextRules(),
                        isEnabled: true,
                        sortOrder: index,
                        parentID: parentID
                    )
                )
            }
        }
    }

    private static func isActionVisible(_ actionID: String, settings: AppSettings) -> Bool {
        guard settings.isActionEnabled(actionID) else {
            return false
        }

        guard BuiltinActionIdentifier.isOpenInTerminalActionID(actionID) else {
            return true
        }

        return AppLauncher.knownTerminalLaunchers.contains { launcher in
            BuiltinActionIdentifier.openInTerminalActionID(for: launcher) == actionID &&
            settings.visibleTerminalLauncherIDs.contains(launcher.id)
        }
    }
}
