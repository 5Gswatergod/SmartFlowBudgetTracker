import Foundation

@MainActor
final class RetentionViewModel: ObservableObject {
    @Published private(set) var prompts: [RetentionPrompt] = []

    private let service: RetentionService

    init(service: RetentionService) {
        self.service = service
        refresh()
    }

    func refresh() {
        prompts = service.fetchPrompts()
    }

    func complete(_ prompt: RetentionPrompt) {
        service.markCompleted(prompt)
        refresh()
    }
}
