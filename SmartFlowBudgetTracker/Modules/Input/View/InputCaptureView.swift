import SwiftUI

struct InputCaptureView: View {
    @EnvironmentObject private var viewModel: InputViewModel
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingMedium) {
            Text("Capture")
                .font(.title3.weight(.semibold))
            Picker("Capture Mode", selection: $viewModel.selectedSource) {
                ForEach(InputSource.allCases) { source in
                    Text(source.displayName).tag(source)
                }
            }
            .pickerStyle(.segmented)

            actionButtons

            if let message = viewModel.statusMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(palette.subheadline)
                    .transition(.opacity)
            }
        }
        .padding(theme.layoutPadding)
        .background(palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    }

    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            Button {
                viewModel.captureQuickExpense()
            } label: {
                Label("Quick expense", systemImage: "bolt.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(palette.accent)
            .disabled(viewModel.isProcessing)

            HStack {
                Button("Scan receipt") {
                    viewModel.importLatestReceipt()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isProcessing)

                Button("Sync bank") {
                    viewModel.syncBank()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isProcessing)
            }
        }
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }
}

#Preview {
    InputCaptureView()
        .environmentObject(InputViewModel(service: InputService(coreDataStack: CoreDataStack(modelName: "Preview"), ledgerService: LedgerService(coreDataStack: CoreDataStack(modelName: "Preview")))))
        .environment(\.appTheme, .cyberFlux)
}
