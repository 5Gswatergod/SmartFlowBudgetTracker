import SwiftUI

@main
struct SmartFlowBudgetTrackerApp: App {
    @StateObject private var aiService: AIService
    @StateObject private var ledgerViewModel: LedgerViewModel
    @StateObject private var inputViewModel: InputViewModel
    @StateObject private var analyticsViewModel: AnalyticsViewModel
    @StateObject private var retentionViewModel: RetentionViewModel
    @StateObject private var paymentViewModel: PaymentViewModel
    @StateObject private var syncViewModel: SyncViewModel

    private let theme: AppTheme

    init() {
        let coreDataStack = CoreDataStack(modelName: "SmartFlowBudgetTracker")
        let ledgerService = LedgerService(coreDataStack: coreDataStack)
        let inputService = InputService(coreDataStack: coreDataStack, ledgerService: ledgerService)
        let aiService = AIService(mode: .mock)
        let analyticsService = AnalyticsService(aiService: aiService)
        let retentionService = RetentionService()
        let paymentManager = IAPManager()
        let cloudSyncService = CloudSyncService(containerIdentifier: "iCloud.com.smartflow.budget")

        _aiService = StateObject(wrappedValue: aiService)
        _ledgerViewModel = StateObject(wrappedValue: LedgerViewModel(service: ledgerService))
        _inputViewModel = StateObject(wrappedValue: InputViewModel(service: inputService))
        _analyticsViewModel = StateObject(wrappedValue: AnalyticsViewModel(service: analyticsService))
        _retentionViewModel = StateObject(wrappedValue: RetentionViewModel(service: retentionService))
        _paymentViewModel = StateObject(wrappedValue: PaymentViewModel(manager: paymentManager))
        _syncViewModel = StateObject(wrappedValue: SyncViewModel(service: cloudSyncService))

        theme = .cyberFlux
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environment(\.appTheme, theme)
            .environmentObject(aiService)
            .environmentObject(ledgerViewModel)
            .environmentObject(inputViewModel)
            .environmentObject(analyticsViewModel)
            .environmentObject(retentionViewModel)
            .environmentObject(paymentViewModel)
            .environmentObject(syncViewModel)
        }
    }
}
