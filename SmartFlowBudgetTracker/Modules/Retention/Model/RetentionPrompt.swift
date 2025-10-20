import Foundation

struct RetentionPrompt: Identifiable, Hashable, Codable {
    enum PromptType: String, Codable {
        case checklist
        case nudge
        case celebration
    }

    let id: UUID
    let type: PromptType
    let title: String
    let detail: String
    let actionTitle: String

    init(id: UUID = UUID(), type: PromptType, title: String, detail: String, actionTitle: String) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.actionTitle = actionTitle
    }
}
