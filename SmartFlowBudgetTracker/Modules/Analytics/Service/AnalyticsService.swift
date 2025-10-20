import Foundation
import Combine

@MainActor
final class AIService: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case mock
        case local
        case remote

        var id: String { rawValue }
        var description: String {
            switch self {
            case .mock: return "Deterministic mock responses"
            case .local: return "On-device transformer"
            case .remote: return "OpenAI GPT endpoint"
            }
        }
    }

    struct Insight: Hashable, Codable {
        let message: String
        let confidence: Double
    }

    @Published private(set) var mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    func updateMode(_ mode: Mode) {
        self.mode = mode
    }

    func generateInsight(for items: [LedgerItem]) async -> Insight {
        switch mode {
        case .mock:
            let total = items.reduce(0) { $0 + $1.amount }
            return Insight(message: "You're trending \(total >= 0 ? "positive" : "negative") this month.", confidence: 0.65)
        case .local:
            try? await Task.sleep(nanoseconds: 120_000_000)
            return Insight(message: "Local model suggests reducing discretionary spending by 10%.", confidence: 0.54)
        case .remote:
            try? await Task.sleep(nanoseconds: 250_000_000)
            return Insight(message: "GPT recommends moving excess cash into a high-yield savings goal.", confidence: 0.72)
        }
    }
}

@MainActor
final class AnalyticsService: ObservableObject {
    private let aiService: AIService

    init(aiService: AIService) {
        self.aiService = aiService
    }

    func summarize(items: [LedgerItem]) async -> (AnalyticsSummary, AIService.Insight) {
        let net = items.reduce(0) { $0 + $1.amount }
        let runRate = net / Double(max(items.count, 1)) * 30

        let breakdown = Dictionary(grouping: items, by: { $0.category })
            .map { key, value in
                AnalyticsSummary.CategoryBreakdown(
                    category: key,
                    total: value.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted(by: { $0.total > $1.total })

        let summary = AnalyticsSummary(
            netCashFlow: net,
            runRate: runRate,
            categoryBreakdown: breakdown,
            topInsight: breakdown.first?.category.displayName ?? "")

        let insight = await aiService.generateInsight(for: items)
        return (summary, insight)
    }
}

private extension LedgerItem.Category {
    var displayName: String {
        rawValue.capitalized
    }
}
