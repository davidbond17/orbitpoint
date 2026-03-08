import SwiftUI

struct PowerUpHUDView: View {

    let powerUpType: PowerUpType
    let timeRemaining: TimeInterval

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: powerUpType.iconName)
                .font(.system(size: 14, weight: .bold))

            if powerUpType != .shield {
                Text("\(Int(ceil(timeRemaining)))s")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.Colors.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var color: Color {
        switch powerUpType {
        case .shield: return Color(red: 0.3, green: 0.8, blue: 1.0)
        case .slowField: return Color(red: 0.6, green: 0.3, blue: 0.9)
        case .magnet: return Color(red: 1.0, green: 0.4, blue: 0.3)
        case .phaseShift: return .white
        case .orbitBoost: return Color(red: 1.0, green: 0.85, blue: 0.2)
        }
    }
}
