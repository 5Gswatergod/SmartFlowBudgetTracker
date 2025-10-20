import Foundation
import Combine
import StoreKit

@MainActor
final class IAPManager: ObservableObject {
    @Published private(set) var availablePlans: [SubscriptionPlan] = []
    @Published private(set) var isPremiumUnlocked: Bool = false

    private let productIdentifiers: [String] = ["com.smartflow.pro", "com.smartflow.enterprise"]

    func loadProducts() async {
        availablePlans = [
            SubscriptionPlan(tier: .free, price: 0, description: "Track expenses with manual input and charts."),
            SubscriptionPlan(tier: .pro, price: 4.99, description: "Unlock AI insights and unlimited bank sync."),
            SubscriptionPlan(tier: .enterprise, price: 14.99, description: "Multi-user controls and export automations.")
        ]
        _ = productIdentifiers
    }

    func purchase(plan: SubscriptionPlan) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        isPremiumUnlocked = plan.tier != .free
    }

    func restore() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
        isPremiumUnlocked.toggle()
    }
}
