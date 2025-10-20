import SwiftUI

struct SyncStatusView: View {
    @EnvironmentObject private var viewModel: SyncViewModel
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            HStack {
                Label("Cloud sync", systemImage: iconName)
                    .font(.headline)
                    .foregroundStyle(theme.palette.accent)
                Spacer()
                if let lastSync = viewModel.status.lastSync {
                    Text(lastSync, style: .time)
                        .font(.caption)
                        .foregroundStyle(theme.palette.subheadline)
                }
            }
            Text(viewModel.status.message ?? "Tap sync to stay current.")
                .font(.footnote)
            Button(action: viewModel.refresh) {
                Label("Sync now", systemImage: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.bordered)
        }
        .padding(theme.layoutPadding)
        .background(theme.palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    }

    private var iconName: String {
        switch viewModel.status.state {
        case .idle: return "icloud"
        case .syncing: return "arrow.triangle.2.circlepath.circle"
        case .success: return "checkmark.icloud"
        case .failure: return "exclamationmark.icloud"
        }
    }
}

#Preview {
    let service = CloudSyncService(containerIdentifier: "iCloud.preview")
    let vm = SyncViewModel(service: service)
    return SyncStatusView()
        .environmentObject(vm)
        .environment(\.appTheme, .cyberDark)
}
