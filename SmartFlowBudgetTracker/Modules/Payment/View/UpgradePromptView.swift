import SwiftUI

struct UpgradePromptView: View {
    @EnvironmentObject private var paymentViewModel: PaymentViewModel
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            HStack {
                Text("Upgrade to unlock automations")
                    .font(.title3.weight(.semibold))
                Spacer()
                if paymentViewModel.isPremiumUnlocked {
                    Label("Pro", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(theme.palette.accent)
                }
            }
            planRows
            HStack {
                Button(paymentViewModel.isPremiumUnlocked ? "Manage" : "Upgrade") {
                    if let plan = paymentViewModel.plans.first(where: { $0.tier == .pro }) {
                        paymentViewModel.purchase(plan: plan)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.palette.accent)
                Button("Restore") {
                    paymentViewModel.restorePurchases()
                }
            }
            if let error = paymentViewModel.purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(theme.palette.negative)
            }
        }
        .padding(theme.layoutPadding)
        .background(theme.palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        .onAppear { paymentViewModel.load() }
    }

    private var planRows: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
            ForEach(paymentViewModel.plans) { plan in
                HStack {
                    VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                        Text(plan.tier.rawValue.capitalized)
                            .font(.headline)
                        Text(plan.description)
                            .font(.caption)
                            .foregroundStyle(theme.palette.subheadline)
                    }
                    Spacer()
                    Text(plan.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.headline.monospacedDigit())
                }
                .padding(theme.layoutSpacingSmall)
                .background(theme.palette.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
            }
        }
    }
}

#Preview {
    UpgradePromptView()
        .environmentObject(PaymentViewModel(manager: IAPManager()))
        .environment(\.appTheme, .cyberDark)
}
