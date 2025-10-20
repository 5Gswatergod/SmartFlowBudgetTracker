import Foundation

struct AnalyticsSummary: Hashable, Codable {
    struct CategoryBreakdown: Hashable, Codable {
        let category: LedgerItem.Category
        let total: Double
    }

    let netCashFlow: Double
    let runRate: Double
    let categoryBreakdown: [CategoryBreakdown]
    let topInsight: String
}
