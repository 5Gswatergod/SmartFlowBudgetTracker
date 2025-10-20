import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var ledgerViewModel: LedgerViewModel
    @EnvironmentObject private var inputViewModel: InputViewModel
    @EnvironmentObject private var analyticsViewModel: AnalyticsViewModel
    @EnvironmentObject private var retentionViewModel: RetentionViewModel
    @EnvironmentObject private var paymentViewModel: PaymentViewModel
    @EnvironmentObject private var syncViewModel: SyncViewModel
    @EnvironmentObject private var aiService: AIService
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: Tab = .ledger

    var body: some View {
        ZStack {
            palette.windowBackground
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                ledgerTab
                    .tabItem { Label("Ledger", systemImage: "list.bullet.rectangle") }
                    .tag(Tab.ledger)

                analyticsTab
                    .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
                    .tag(Tab.analytics)

                inputTab
                    .tabItem { Label("Capture", systemImage: "bolt.fill") }
                    .tag(Tab.input)

                retentionTab
                    .tabItem { Label("Retention", systemImage: "person.2.wave.2") }
                    .tag(Tab.retention)

                syncTab
                    .tabItem { Label("Sync", systemImage: "arrow.clockwise") }
                    .tag(Tab.sync)

                upgradeTab
                    .tabItem { Label("Upgrade", systemImage: "sparkles") }
                    .tag(Tab.upgrade)
            }
        }
        .onAppear {
            ledgerViewModel.refresh()
            retentionViewModel.refresh()
            syncViewModel.refresh()
            paymentViewModel.load()
            Task { await analyticsViewModel.refresh(using: ledgerViewModel.items) }
        }
        .onChange(of: ledgerViewModel.items) { newValue in
            Task { await analyticsViewModel.refresh(using: newValue) }
        }
        .onChange(of: inputViewModel.lastImportedItem) { _ in
            ledgerViewModel.refresh()
        }
    }

    private enum Tab: Hashable {
        case ledger, analytics, input, retention, sync, upgrade
    }

    private var ledgerTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.layoutSpacingLarge) {
                header
                LedgerDashboardView()
                    .environmentObject(ledgerViewModel)
            }
            .padding(theme.layoutPadding)
        }
    }

    private var analyticsTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.layoutSpacingLarge) {
                AnalyticsOverviewView()
                    .environmentObject(analyticsViewModel)
            }
            .padding(theme.layoutPadding)
        }
    }

    private var inputTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.layoutSpacingLarge) {
                InputCaptureView()
                    .environmentObject(inputViewModel)
            }
            .padding(theme.layoutPadding)
        }
    }

    private var retentionTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.layoutSpacingLarge) {
                RetentionPromptView()
                    .environmentObject(retentionViewModel)
            }
            .padding(theme.layoutPadding)
        }
    }

    private var syncTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.layoutSpacingLarge) {
                SyncStatusView()
                    .environmentObject(syncViewModel)
            }
            .padding(theme.layoutPadding)
        }
    }

    private var upgradeTab: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.layoutSpacingLarge) {
                UpgradePromptView()
                    .environmentObject(paymentViewModel)
            }
            .padding(theme.layoutPadding)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            HStack {
                VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                    Text("SmartFlow Dashboard")
                        .font(.largeTitle.bold())
                    Text("Your automated budget co-pilot")
                        .font(.subheadline)
                        .foregroundStyle(palette.subheadline)
                }
                Spacer()
                Menu {
                    ForEach(AIService.Mode.allCases) { mode in
                        Button {
                            aiService.updateMode(mode)
                            Task { await analyticsViewModel.refresh(using: ledgerViewModel.items) }
                        } label: {
                            HStack {
                                Text(mode.description)
                                if mode == aiService.mode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label("AI mode: \(aiService.mode.rawValue.capitalized)", systemImage: "slider.horizontal.3")
                        .padding(.horizontal, theme.layoutSpacingSmall)
                        .padding(.vertical, theme.layoutSpacingXSmall)
                        .background(palette.cardBackground)
                        .clipShape(Capsule())
                }
            }
            Text("Latest sync: \(syncViewModel.status.lastSync?.formatted(date: .numeric, time: .shortened) ?? "--")")
                .font(.caption)
                .foregroundStyle(palette.subheadline)
        }
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

#Preview {
    let coreDataStack = CoreDataStack(modelName: "Preview")
    let ledgerService = LedgerService(coreDataStack: coreDataStack)
    let ledgerVM = LedgerViewModel(service: ledgerService)
    let aiService = AIService(mode: .mock)
    let analyticsService = AnalyticsService(aiService: aiService)
    let analyticsVM = AnalyticsViewModel(service: analyticsService)
    let inputService = InputService(coreDataStack: coreDataStack, ledgerService: ledgerService)
    let inputVM = InputViewModel(service: inputService)
    let retentionVM = RetentionViewModel(service: RetentionService(userDefaults: .standard))
    let paymentVM = PaymentViewModel(manager: IAPManager())
    let syncVM = SyncViewModel(service: CloudSyncService(containerIdentifier: "iCloud.preview"))
    return NavigationStack {
        ContentView()
            .environmentObject(ledgerVM)
            .environmentObject(inputVM)
            .environmentObject(analyticsVM)
            .environmentObject(retentionVM)
            .environmentObject(paymentVM)
            .environmentObject(syncVM)
            .environmentObject(aiService)
    }
    .environment(\.appTheme, .cyberFlux)
}
