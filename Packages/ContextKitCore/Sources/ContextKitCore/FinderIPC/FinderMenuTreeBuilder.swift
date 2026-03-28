import Foundation

public struct FinderMenuTreeBuilder {
    public init() {}

    public func build(
        descriptors: [MenuDescriptor],
        snapshot: ContextSnapshot
    ) -> [FinderMenuNode] {
        let visibleLeaves = descriptors.filter { descriptor in
            descriptor.kind != .group &&
            descriptor.isEnabled &&
            descriptor.contextRules.matches(snapshot: snapshot)
        }

        let descriptorsByID = Dictionary(uniqueKeysWithValues: descriptors.map { ($0.id, $0) })
        var visibleIDs = Set(visibleLeaves.map(\.id))

        for leaf in visibleLeaves {
            var currentParentID = leaf.parentID
            while let parentID = currentParentID, let parent = descriptorsByID[parentID] {
                visibleIDs.insert(parent.id)
                currentParentID = parent.parentID
            }
        }

        let visibleDescriptors = descriptors.filter { visibleIDs.contains($0.id) }
        return makeNodes(parentID: nil, descriptors: visibleDescriptors)
    }

    private func makeNodes(
        parentID: String?,
        descriptors: [MenuDescriptor]
    ) -> [FinderMenuNode] {
        let childDescriptors = descriptors
            .filter { $0.parentID == parentID }
            .sorted(by: { $0.sortOrder < $1.sortOrder })

        return childDescriptors.compactMap { descriptor in
            switch descriptor.kind {
            case .group:
                let children = makeNodes(parentID: descriptor.id, descriptors: descriptors)
                guard !children.isEmpty else {
                    return nil
                }

                return FinderMenuNode(
                    id: descriptor.id,
                    title: descriptor.title,
                    kind: .group,
                    enabled: true,
                    children: children
                )
            case .action:
                return FinderMenuNode(
                    id: descriptor.id,
                    title: descriptor.title,
                    kind: .action,
                    targetType: .action
                )
            case .workflow:
                return FinderMenuNode(
                    id: descriptor.id,
                    title: descriptor.title,
                    kind: .workflow,
                    targetType: .workflow
                )
            }
        }
    }
}
