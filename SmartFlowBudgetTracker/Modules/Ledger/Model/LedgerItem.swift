import Foundation

struct LedgerItem: Identifiable, Hashable, Codable {
    enum Category: String, CaseIterable, Codable {
        case income
        case housing
        case food
        case transportation
        case entertainment
        case savings
        case utilities
        case miscellaneous

        var systemImageName: String {
            switch self {
            case .income: return "arrow.down.circle"
            case .housing: return "house.fill"
            case .food: return "fork.knife"
            case .transportation: return "car.fill"
            case .entertainment: return "sparkles"
            case .savings: return "banknote.fill"
            case .utilities: return "bolt.fill"
            case .miscellaneous: return "circle.grid.2x2"
            }
        }
    }

    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let category: Category
    let notes: String?

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = .now,
        category: Category,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.notes = notes
    }
}

extension LedgerItem {
    static let previewTransactions: [LedgerItem] = [
        .init(title: "Paycheck", amount: 3200, category: .income),
        .init(title: "Rent", amount: -1450, category: .housing),
        .init(title: "Groceries", amount: -185.27, category: .food),
        .init(title: "Streaming Services", amount: -42.99, category: .entertainment),
        .init(title: "Fuel", amount: -65.11, category: .transportation),
        .init(title: "Savings Transfer", amount: -250, category: .savings)
    ]
}
