import SwiftUI

struct AppTheme {
    struct Palette {
        let windowBackground: Color
        let panelBackground: Color
        let cardBackground: Color
        let badgeBackground: Color
        let accent: Color
        let positive: Color
        let negative: Color
        let subheadline: Color
        let shadow: Color
        let chartGradient: LinearGradient
    }

    let lightPalette: Palette
    let darkPalette: Palette
    let cornerRadius: CGFloat
    let layoutPadding: CGFloat
    let layoutSpacingXSmall: CGFloat
    let layoutSpacingSmall: CGFloat
    let layoutSpacingMedium: CGFloat
    let layoutSpacingLarge: CGFloat

    func palette(for colorScheme: ColorScheme) -> Palette {
        colorScheme == .dark ? darkPalette : lightPalette
    }

    static let cyberFlux: AppTheme = {
        let accent = Color(red: 0.23, green: 0.84, blue: 0.86)
        let chartGradient = LinearGradient(
            colors: [accent, Color.purple.opacity(0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )

        return AppTheme(
            lightPalette: Palette(
                windowBackground: Color(red: 245 / 255, green: 248 / 255, blue: 255 / 255),
                panelBackground: Color(red: 228 / 255, green: 236 / 255, blue: 255 / 255),
                cardBackground: Color.white,
                badgeBackground: Color(red: 218 / 255, green: 242 / 255, blue: 255 / 255),
                accent: accent,
                positive: Color(red: 0.18, green: 0.6, blue: 0.36),
                negative: Color(red: 0.75, green: 0.18, blue: 0.31),
                subheadline: Color.black.opacity(0.6),
                shadow: Color.black.opacity(0.15),
                chartGradient: LinearGradient(
                    colors: [accent, Color.purple.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            ),
            darkPalette: Palette(
                windowBackground: Color(red: 7 / 255, green: 12 / 255, blue: 26 / 255),
                panelBackground: Color(red: 17 / 255, green: 24 / 255, blue: 42 / 255),
                cardBackground: Color(red: 25 / 255, green: 34 / 255, blue: 58 / 255),
                badgeBackground: Color.white.opacity(0.06),
                accent: accent,
                positive: Color(red: 0.42, green: 0.95, blue: 0.64),
                negative: Color(red: 0.97, green: 0.32, blue: 0.48),
                subheadline: Color.white.opacity(0.65),
                shadow: Color.black.opacity(0.7),
                chartGradient: chartGradient
            ),
            cornerRadius: 18,
            layoutPadding: 16,
            layoutSpacingXSmall: 6,
            layoutSpacingSmall: 10,
            layoutSpacingMedium: 18,
            layoutSpacingLarge: 28
        )
    }()
}

private struct AppThemeKey: EnvironmentKey {
    static var defaultValue: AppTheme = .cyberFlux
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

private struct NeonBorderModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let palette = theme.palette(for: colorScheme)
        return content
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(palette.accent.gradient, lineWidth: 1)
            )
            .shadow(color: palette.accent.opacity(0.35), radius: 12, x: 0, y: 6)
    }
}

private struct SoftPanelBackgroundModifier: ViewModifier {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let palette = theme.palette(for: colorScheme)
        return content
            .padding(theme.layoutPadding)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .fill(palette.panelBackground)
            )
    }
}

extension View {
    func neonBorder() -> some View {
        modifier(NeonBorderModifier())
    }

    func softPanelBackground() -> some View {
        modifier(SoftPanelBackgroundModifier())
    }
}

private extension Color {
    var gradient: LinearGradient {
        LinearGradient(colors: [self, self.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
    }
}
