import SwiftUI
import SpriteKit

enum Theme {
    enum Colors {
        static let background = Color(red: 0.02, green: 0.02, blue: 0.06)
        static let backgroundSK = SKColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1.0)

        static let starCore = Color(red: 1.0, green: 0.95, blue: 0.8)
        static let starCoreSK = SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
        static let starGlow = Color(red: 1.0, green: 0.6, blue: 0.2)
        static let starGlowSK = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.6)

        static let satellite = Color(red: 0.4, green: 0.8, blue: 1.0)
        static let satelliteSK = SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        static let satelliteTrail = Color(red: 0.3, green: 0.6, blue: 0.9)
        static let satelliteTrailSK = SKColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.4)

        static let debris = Color(red: 0.6, green: 0.2, blue: 0.3)
        static let debrisSK = SKColor(red: 0.6, green: 0.2, blue: 0.3, alpha: 1.0)

        static let textPrimary = Color.white
        static let textSecondary = Color(white: 0.7)

        static let glassBackground = Color.white.opacity(0.08)
        static let glassBorder = Color.white.opacity(0.2)
        static let glassHighlight = Color.white.opacity(0.15)

        static let accent = Color(red: 0.4, green: 0.8, blue: 1.0)
        static let accentGlow = Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.5)
    }

    enum Dimensions {
        static let starRadius: CGFloat = 30
        static let satelliteRadius: CGFloat = 8
        static let orbitRadius: CGFloat = 120
        static let debrisMinSize: CGFloat = 6
        static let debrisMaxSize: CGFloat = 14

        static let glassCornerRadius: CGFloat = 20
        static let glassBorderWidth: CGFloat = 1
        static let buttonHeight: CGFloat = 56
    }

    enum Animation {
        static let orbitSpeed: CGFloat = 2.0
        static let glowPulseSpeed: CGFloat = 1.5
        static let trailFadeDuration: TimeInterval = 0.5
    }
}

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.glassCornerRadius)
                    .fill(Theme.Colors.glassBackground)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Dimensions.glassCornerRadius)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Dimensions.glassCornerRadius)
                            .stroke(Theme.Colors.glassBorder, lineWidth: Theme.Dimensions.glassBorderWidth)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Dimensions.glassCornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [Theme.Colors.glassHighlight, .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: Theme.Dimensions.glassBorderWidth
                            )
                    )
            )
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
}

struct GlassButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Dimensions.buttonHeight)
            .glassBackground()
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticsManager.shared.playButtonPress()
                    AudioManager.shared.playButtonTap()
                }
            }
    }
}

extension ButtonStyle where Self == GlassButton {
    static var glass: GlassButton { GlassButton() }
}
