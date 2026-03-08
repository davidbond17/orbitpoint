import SwiftUI

struct PowerUpCollectedToast: View {

    let type: PowerUpType
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 10) {
                Image(systemName: type.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)

                Text(type.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.Colors.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.bottom, 80)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    onDismiss()
                }
            }
        }
    }

    private var color: Color {
        switch type {
        case .shield: return Color(red: 0.3, green: 0.8, blue: 1.0)
        case .slowField: return Color(red: 0.6, green: 0.3, blue: 0.9)
        case .magnet: return Color(red: 1.0, green: 0.4, blue: 0.3)
        case .phaseShift: return .white
        case .orbitBoost: return Color(red: 1.0, green: 0.85, blue: 0.2)
        }
    }
}
