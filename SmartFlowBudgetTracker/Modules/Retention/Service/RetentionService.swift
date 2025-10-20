import Foundation

@MainActor
final class RetentionService: ObservableObject {
    @Published private(set) var completedPromptIDs: Set<UUID>
    private let storageKey = "retention.prompts.completed"

    init(userDefaults: UserDefaults = .standard) {
        if let data = userDefaults.array(forKey: storageKey) as? [String] {
            completedPromptIDs = Set(data.compactMap(UUID.init(uuidString:)))
        } else {
            completedPromptIDs = []
        }
        self.userDefaults = userDefaults
    }

    private let userDefaults: UserDefaults

    func fetchPrompts() -> [RetentionPrompt] {
        let prompts = [
            RetentionPrompt(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, type: .checklist, title: "Review recurring payments", detail: "Audit the subscriptions charged this month.", actionTitle: "Review"),
            RetentionPrompt(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, type: .nudge, title: "Celebrate savings streak", detail: "You're 4 weeks into your savings plan.", actionTitle: "Share"),
            RetentionPrompt(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, type: .nudge, title: "Log receipts", detail: "Keep your ledger fresh by logging today's receipts.", actionTitle: "Log now")
        ]
        return prompts.filter { !completedPromptIDs.contains($0.id) }
    }

    func markCompleted(_ prompt: RetentionPrompt) {
        completedPromptIDs.insert(prompt.id)
        persistState()
    }

    private func persistState() {
        let identifiers = completedPromptIDs.map(\.uuidString)
        userDefaults.set(identifiers, forKey: storageKey)
    }
}
