import SwiftUI

struct AnalyticsOverviewView: View {
    @EnvironmentObject private var analyticsViewModel: AnalyticsViewModel
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: theme.layoutSpacingMedium) {
            chartCard
            AIInsightBubble(insight: analyticsViewModel.aiInsight)
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            Text("Analytics")
                .font(.title3.weight(.semibold))
            HStack(alignment: .top, spacing: theme.layoutSpacingMedium) {
                VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                    Text("Net cash flow")
                        .font(.caption)
                        .foregroundStyle(palette.subheadline)
                    Text(analyticsViewModel.summary.netCashFlow, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(analyticsViewModel.summary.netCashFlow >= 0 ? palette.positive : palette.negative)
                }
                Spacer()
                VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                    Text("Run rate (30d)")
                        .font(.caption)
                        .foregroundStyle(palette.subheadline)
                    Text(analyticsViewModel.summary.runRate, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.headline)
                        .foregroundStyle(palette.accent)
                }
            }

            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text("Top categories")
                    .font(.caption)
                    .foregroundStyle(palette.subheadline)
                ForEach(analyticsViewModel.summary.categoryBreakdown.prefix(3), id: \.category) { breakdown in
                    CategoryBarView(breakdown: breakdown)
                }
                if !analyticsViewModel.summary.topInsight.isEmpty {
                    Text("Focus area: \(analyticsViewModel.summary.topInsight)")
                        .font(.caption)
                        .foregroundStyle(palette.subheadline)
                        .padding(.top, theme.layoutSpacingXSmall)
                }
            }
        }
        .padding(theme.layoutPadding)
        .background(palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

private struct CategoryBarView: View {
    let breakdown: AnalyticsSummary.CategoryBreakdown
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
            HStack {
                Text(breakdown.category.displayName)
                    .font(.footnote)
                Spacer()
                Text(breakdown.total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(breakdown.total >= 0 ? palette.positive : palette.negative)
            }
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: theme.cornerRadius / 2)
                    .fill(palette.chartGradient)
                    .frame(width: max(geometry.size.width * CGFloat(min(abs(breakdown.total) / 2000, 1)), 8), height: 6)
            }
            .frame(height: 6)
        }
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

private struct AIInsightBubble: View {
    let insight: AIService.Insight?
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            HStack {
                Label("AI Insight", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(palette.accent)
                Spacer()
                if let insight {
                    Text("Confidence: \(Int(insight.confidence * 100))%")
                        .font(.caption)
                        .foregroundStyle(palette.subheadline)
                }
            }
            Text(insight?.message ?? "Insights will appear here once data is available.")
                .font(.callout)
        }
        .padding(theme.layoutPadding)
        .background(palette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        .shadow(color: palette.shadow.opacity(0.25), radius: 12, x: 0, y: 6)
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

private extension LedgerItem.Category {
    var displayName: String {
        rawValue.capitalized
    }
}

#Preview {
    let analyticsService = AnalyticsService(aiService: AIService(mode: .mock))
    let vm = AnalyticsViewModel(service: analyticsService)
    Task { @MainActor in
        await vm.refresh(using: LedgerItem.previewTransactions)
    }
    return AnalyticsOverviewView()
        .environmentObject(vm)
        .environment(\.appTheme, .cyberFlux)
}
