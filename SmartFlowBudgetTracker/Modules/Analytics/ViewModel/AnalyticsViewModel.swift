import Foundation

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published private(set) var summary: AnalyticsSummary
    @Published private(set) var aiInsight: AIService.Insight?

    private let service: AnalyticsService

    init(service: AnalyticsService) {
        self.service = service
        self.summary = AnalyticsSummary(
            netCashFlow: 0,
            runRate: 0,
            categoryBreakdown: [],
            topInsight: "")
    }

    func refresh(using items: [LedgerItem]) async {
        let result = await service.summarize(items: items)
        summary = result.0
        aiInsight = result.1
    }
}
