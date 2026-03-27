import Foundation

public struct RuntimeCatalog: Sendable {
    public var actions: [ActionManifest]
    public var workflows: [WorkflowManifest]
    public var menuDescriptors: [MenuDescriptor]

    public init(actions: [ActionManifest], workflows: [WorkflowManifest], menuDescriptors: [MenuDescriptor]) {
        self.actions = actions
        self.workflows = workflows
        self.menuDescriptors = menuDescriptors
    }
}
