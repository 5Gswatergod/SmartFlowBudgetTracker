import Foundation

struct SubscriptionPlan: Identifiable, Hashable, Codable {
    enum Tier: String, Codable {
        case free
        case pro
        case enterprise
    }

    let id: UUID
    let tier: Tier
    let price: Double
    let description: String

    init(id: UUID = UUID(), tier: Tier, price: Double, description: String) {
        self.id = id
        self.tier = tier
        self.price = price
        self.description = description
    }
}
