import SwiftUI

struct RetentionPromptView: View {
    @EnvironmentObject private var viewModel: RetentionViewModel
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

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
                    .foregroundStyle(palette.subheadline)
            }
        }
        .padding(theme.layoutPadding)
        .background(palette.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
    }

    private var palette: AppTheme.Palette {
        theme.palette(for: colorScheme)
    }

    private struct PromptRow: View {
        let prompt: RetentionPrompt
        @EnvironmentObject private var viewModel: RetentionViewModel
        @Environment(\.appTheme) private var theme
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            VStack(alignment: .leading, spacing: theme.layoutSpacingXSmall) {
                Text(prompt.title)
                    .font(.headline)
                Text(prompt.detail)
                    .font(.caption)
                    .foregroundStyle(palette.subheadline)
                Button(prompt.actionTitle) {
                    viewModel.complete(prompt)
                }
                .buttonStyle(.borderedProminent)
                .tint(palette.accent)
            }
            .padding(theme.layoutSpacingSmall)
            .background(palette.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
        }

        private var palette: AppTheme.Palette {
            theme.palette(for: colorScheme)
        }
    }
}

#Preview {
    RetentionPromptView()
        .environmentObject(RetentionViewModel(service: RetentionService(userDefaults: .standard)))
        .environment(\.appTheme, .cyberFlux)
}
