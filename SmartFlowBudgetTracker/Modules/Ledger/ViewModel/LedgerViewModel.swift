import Foundation
import Combine

@MainActor
final class LedgerViewModel: ObservableObject {
    @Published private(set) var items: [LedgerItem] = []
    @Published private(set) var totalSpending: Double = 0
    @Published private(set) var categoryTotals: [LedgerItem.Category: Double] = [:]

    private let service: LedgerService

    init(service: LedgerService) {
        self.service = service
        refresh()
    }

    func refresh() {
        items = service.fetchLedgerItems()
        recalculateMetrics()
    }

    func registerImported(item: LedgerItem) {
        service.addTransaction(item)
        refresh()
    }

    func remove(item: LedgerItem) {
        service.deleteTransaction(id: item.id)
        refresh()
    }

    private func recalculateMetrics() {
        totalSpending = items.reduce(0) { $0 + $1.amount }

        categoryTotals = Dictionary(grouping: items, by: { $0.category })
            .mapValues { groupedItems in
                groupedItems.reduce(0) { $0 + $1.amount }
            }
    }
}
