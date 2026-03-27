import ContextKitCore
import Foundation

@MainActor
final class WorkflowsViewModel: ObservableObject {
    @Published var workflows: [WorkflowManifest] = []
    @Published var availableActions: [ActionManifest] = []
    @Published var isPresentingEditor = false
    @Published var draft = WorkflowDraft()
    @Published var errorMessage: String?

    private let services: ContextKitAppServices

    init(services: ContextKitAppServices) {
        self.services = services
    }

    func reload() {
        do {
            workflows = try services.loadWorkflows()
            availableActions = try services.loadCatalog().actions
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createWorkflow() {
        draft = WorkflowDraft(
            name: L10n.string("app.workflows.defaultName", fallback: "New Workflow"),
            steps: availableActions.prefix(2).enumerated().map { index, manifest in
                WorkflowDraftStep(
                    actionID: manifest.id,
                    input: index == 0 ? .selection : .previousFiles
                )
            }
        )
        isPresentingEditor = true
    }

    func edit(_ workflow: WorkflowManifest) {
        draft = WorkflowDraft(workflow: workflow)
        isPresentingEditor = true
    }

    func addStep() {
        guard let firstAction = availableActions.first else { return }
        draft.steps.append(WorkflowDraftStep(actionID: firstAction.id, input: .previousFiles))
    }

    func saveDraft() {
        do {
            try services.saveWorkflow(name: draft.name, steps: draft.steps, existingID: draft.id)
            isPresentingEditor = false
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ workflow: WorkflowManifest) {
        do {
            try services.removeWorkflow(workflow)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
