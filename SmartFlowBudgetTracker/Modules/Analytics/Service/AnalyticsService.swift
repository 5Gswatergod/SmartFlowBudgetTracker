import Foundation

@MainActor
final class AnalyticsService {
    private let aiService: AIService

    init(aiService: AIService) {
        self.aiService = aiService
    }

    func summarize(items: [LedgerItem]) async -> (AnalyticsSummary, AIService.Insight) {
        let net = items.reduce(0) { running, item in running + item.amount }
        let averageDaily = items.isEmpty ? 0 : net / Double(items.count)
        let runRate = averageDaily * 30

        var totals: [LedgerItem.Category: Double] = [:]
        for item in items {
            totals[item.category, default: 0] += item.amount
        }

        let breakdown = totals
            .map { entry in
                AnalyticsSummary.CategoryBreakdown(
                    category: entry.key,
                    total: entry.value
                )
            }
            .sorted { $0.total > $1.total }

        let summary = AnalyticsSummary(
            netCashFlow: net,
            runRate: runRate,
            categoryBreakdown: breakdown,
            topInsight: breakdown.first?.category.displayName ?? ""
        )

        let insight = await aiService.generateInsight(for: items)
        return (summary, insight)
    }
}

private extension LedgerItem.Category {
    var displayName: String {
        rawValue.capitalized
    }
}
