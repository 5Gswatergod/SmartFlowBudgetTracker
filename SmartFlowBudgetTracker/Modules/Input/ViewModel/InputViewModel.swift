import Foundation
import Combine

@MainActor
final class InputViewModel: ObservableObject {
    @Published var selectedSource: InputSource = .manual
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String?
    @Published private(set) var lastImportedItem: LedgerItem?

    private let service: InputService

    init(service: InputService) {
        self.service = service
    }

    func captureQuickExpense() {
        Task {
            await submitManualEntry(title: "Quick Expense", amount: -9.99, category: .miscellaneous)
        }
    }

    func submitManualEntry(title: String, amount: Double, category: LedgerItem.Category) async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        let item = await service.processManualEntry(title: title, amount: amount, category: category)
        lastImportedItem = item
        statusMessage = "Recorded \(item.title) for \(String(format: "%.2f", item.amount))"
    }

    func importLatestReceipt() {
        Task {
            do {
                isProcessing = true
                defer { isProcessing = false }
                let receiptData = Data()
                let item = try await service.importReceipt(imageData: receiptData)
                lastImportedItem = item
                statusMessage = "Imported \(item.title)"
            } catch {
                statusMessage = "Receipt import failed: \(error.localizedDescription)"
            }
        }
    }

    func syncBank() {
        Task {
            isProcessing = true
            defer { isProcessing = false }
            let items = await service.syncBankTransactions()
            lastImportedItem = items.last
            statusMessage = "Added \(items.count) bank transactions"
        }
    }
}
