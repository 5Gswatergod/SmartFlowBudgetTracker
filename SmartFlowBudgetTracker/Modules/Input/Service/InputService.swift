import Foundation
import CoreData

@MainActor
final class InputService: ObservableObject {
    private let coreDataStack: CoreDataStack
    private let ledgerService: LedgerService

    init(coreDataStack: CoreDataStack, ledgerService: LedgerService) {
        self.coreDataStack = coreDataStack
        self.ledgerService = ledgerService
    }

    func processManualEntry(title: String, amount: Double, category: LedgerItem.Category) async -> LedgerItem {
        let newItem = LedgerItem(title: title, amount: amount, category: category)
        ledgerService.addTransaction(newItem)
        cacheForPreview(item: newItem)
        return newItem
    }

    func importReceipt(imageData: Data) async throws -> LedgerItem {
        try await Task.sleep(nanoseconds: 150_000_000)
        let inferredAmount = -32.45
        let item = LedgerItem(title: "Receipt", amount: inferredAmount, category: .food, notes: "Imported from OCR")
        ledgerService.addTransaction(item)
        cacheForPreview(item: item)
        return item
    }

    func syncBankTransactions() async -> [LedgerItem] {
        let transactions = [
            LedgerItem(title: "Coffee Shop", amount: -6.75, category: .food),
            LedgerItem(title: "Transit Pass", amount: -25.0, category: .transportation)
        ]
        transactions.forEach { transaction in
            ledgerService.addTransaction(transaction)
            cacheForPreview(item: transaction)
        }
        return transactions
    }

    private func cacheForPreview(item: LedgerItem) {
        let context = coreDataStack.container.viewContext
        context.perform {
            _ = item
        }
    }
}
