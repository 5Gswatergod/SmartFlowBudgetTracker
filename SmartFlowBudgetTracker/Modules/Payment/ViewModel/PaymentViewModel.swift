import Foundation

@MainActor
final class PaymentViewModel: ObservableObject {
    @Published private(set) var plans: [SubscriptionPlan] = []
    @Published private(set) var isPremiumUnlocked: Bool = false
    @Published var purchaseError: String?

    private let manager: IAPManager

    init(manager: IAPManager) {
        self.manager = manager
    }

    func load() {
        Task { @MainActor in
            await manager.loadProducts()
            plans = manager.availablePlans
            isPremiumUnlocked = manager.isPremiumUnlocked
        }
    }

    func purchase(plan: SubscriptionPlan) {
        Task { @MainActor in
            do {
                try await manager.purchase(plan: plan)
                isPremiumUnlocked = manager.isPremiumUnlocked
            } catch {
                purchaseError = error.localizedDescription
            }
        }
    }

    func restorePurchases() {
        Task { @MainActor in
            await manager.restore()
            isPremiumUnlocked = manager.isPremiumUnlocked
        }
    }
}
