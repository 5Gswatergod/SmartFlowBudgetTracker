import SwiftUI

struct LedgerDashboardView: View {
    @EnvironmentObject private var viewModel: LedgerViewModel
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingMedium) {
            header
            VStack(spacing: theme.layoutSpacingSmall) {
                ForEach(viewModel.items.prefix(6)) { item in
                    LedgerRowView(item: item)
                        .padding(.horizontal, theme.layoutPadding)
                        .padding(.vertical, theme.layoutSpacingXSmall)
                        .background(palette.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                        .overlay(alignment: .topLeading) {
                            if item.amount > 0 {
                                Capsule()
                                    .fill(palette.accent)
                                    .frame(width: 6)
                                    .padding(.leading, -theme.layoutPadding)
                            }
                        }
                }
            }
        }
        .padding(theme.layoutPadding)
        .background(palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        .shadow(color: palette.shadow.opacity(0.35), radius: 16, x: 0, y: 8)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text("Ledger Overview")
                    .font(.title2.weight(.semibold))
                Text(viewModel.totalSpending, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(viewModel.totalSpending >= 0 ? palette.positive : palette.negative)
            }
            Spacer()
            NavigationLink("See all") {
                LedgerListView(items: viewModel.items)
                    .environmentObject(viewModel)
            }
            .buttonStyle(.borderedProminent)
            .tint(palette.accent)
        }
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

private struct LedgerRowView: View {
    let item: LedgerItem
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: theme.layoutSpacingMedium) {
            Image(systemName: item.category.systemImageName)
                .frame(width: 30, height: 30)
                .foregroundStyle(palette.accent)
                .background(palette.badgeBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius / 2))
            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text(item.title)
                    .font(.headline)
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(palette.subheadline)
            }
            Spacer()
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.headline.monospacedDigit())
                .foregroundStyle(item.amount >= 0 ? palette.positive : palette.negative)
        }
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

private struct LedgerListView: View {
    let items: [LedgerItem]
    @EnvironmentObject private var viewModel: LedgerViewModel
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(palette.subheadline)
                    }
                    Spacer()
                    Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .foregroundStyle(item.amount >= 0 ? palette.positive : palette.negative)
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

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

#Preview {
    LedgerDashboardView()
        .environmentObject(LedgerViewModel(service: LedgerService(coreDataStack: CoreDataStack(modelName: "Preview"))))
        .environment(\.appTheme, .cyberFlux)
        .padding()
        .background(AppTheme.cyberFlux.palette(for: .dark).windowBackground)
}
