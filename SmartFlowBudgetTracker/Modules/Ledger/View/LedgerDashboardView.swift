import SwiftUI

struct LedgerDashboardView: View {
    @EnvironmentObject private var viewModel: LedgerViewModel
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingMedium) {
            header
            VStack(spacing: theme.layoutSpacingSmall) {
                ForEach(viewModel.items.prefix(6)) { item in
                    LedgerRowView(item: item)
                        .padding(.horizontal, theme.layoutPadding)
                        .padding(.vertical, theme.layoutSpacingXSmall)
                        .background(theme.palette.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                        .overlay(alignment: .topLeading) {
                            if item.amount > 0 {
                                Capsule()
                                    .fill(theme.palette.accent)
                                    .frame(width: 6)
                                    .padding(.leading, -theme.layoutPadding)
                            }
                        }
                }
            }
        }
        .padding(theme.layoutPadding)
        .background(theme.palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        .shadow(color: theme.palette.shadow.opacity(0.35), radius: 16, x: 0, y: 8)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text("Ledger Overview")
                    .font(.title2.weight(.semibold))
                Text(viewModel.totalSpending, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(viewModel.totalSpending >= 0 ? theme.palette.positive : theme.palette.negative)
            }
            Spacer()
            NavigationLink("See all") {
                LedgerListView(items: viewModel.items)
                    .environmentObject(viewModel)
            }
            .buttonStyle(.borderedProminent)
            .tint(theme.palette.accent)
        }
    }
}

private struct LedgerRowView: View {
    let item: LedgerItem
    @Environment(\.appTheme) private var theme

    var body: some View {
        HStack(spacing: theme.layoutSpacingMedium) {
            Image(systemName: item.category.systemImageName)
                .frame(width: 30, height: 30)
                .foregroundStyle(theme.palette.accent)
                .background(theme.palette.badgeBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius / 2))
            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text(item.title)
                    .font(.headline)
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(theme.palette.subheadline)
            }
            Spacer()
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.headline.monospacedDigit())
                .foregroundStyle(item.amount >= 0 ? theme.palette.positive : theme.palette.negative)
        }
    }
}

private struct LedgerListView: View {
    let items: [LedgerItem]
    @EnvironmentObject private var viewModel: LedgerViewModel
    @Environment(\.appTheme) private var theme

    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(theme.palette.subheadline)
                    }
                    Spacer()
                    Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .foregroundStyle(item.amount >= 0 ? theme.palette.positive : theme.palette.negative)
                }
                .swipeActions(allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.remove(item: item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Ledger")
    }
}

#Preview {
    LedgerDashboardView()
        .environmentObject(LedgerViewModel(service: LedgerService(coreDataStack: CoreDataStack(modelName: "Preview"))))
        .environment(\.appTheme, .cyberDark)
        .padding()
        .background(AppTheme.cyberDark.palette.windowBackground)
}
