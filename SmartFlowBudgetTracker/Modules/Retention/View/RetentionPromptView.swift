import SwiftUI

struct RetentionPromptView: View {
    @EnvironmentObject private var viewModel: RetentionViewModel
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.layoutSpacingSmall) {
            Text("Stay on track")
                .font(.title3.weight(.semibold))
            ForEach(viewModel.prompts) { prompt in
                PromptRow(prompt: prompt)
            }
            if viewModel.prompts.isEmpty {
                Text("You're all caught up for today.")
                    .font(.footnote)
                    .foregroundStyle(theme.palette.subheadline)
            }
        }
        .padding(theme.layoutPadding)
        .background(theme.palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    }

    private struct PromptRow: View {
        let prompt: RetentionPrompt
        @EnvironmentObject private var viewModel: RetentionViewModel
        @Environment(\.appTheme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text(prompt.title)
                    .font(.headline)
                Text(prompt.detail)
                    .font(.caption)
                    .foregroundStyle(theme.palette.subheadline)
                Button(prompt.actionTitle) {
                    viewModel.complete(prompt)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.palette.accent)
            }
            .padding(theme.layoutSpacingSmall)
            .background(theme.palette.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        }
    }
}

#Preview {
    RetentionPromptView()
        .environmentObject(RetentionViewModel(service: RetentionService(userDefaults: .standard)))
        .environment(\.appTheme, .cyberDark)
}
