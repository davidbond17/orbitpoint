import SwiftUI

struct HowToPlayView: View {

    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text("How to Play")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.top, 8)

            VStack(spacing: 24) {
                TutorialRow(
                    icon: "hand.tap.fill",
                    title: "Tap to Reverse",
                    description: "Tap anywhere to change your satellite's orbit direction"
                )

                TutorialRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Avoid Debris",
                    description: "Dodge the space debris flying toward the sun"
                )

                TutorialRow(
                    icon: "clock.fill",
                    title: "Survive",
                    description: "Each second you survive earns you 1 coin"
                )

                TutorialRow(
                    icon: "bag.fill",
                    title: "Customize",
                    description: "Spend coins in the store to unlock new colors and themes"
                )
            }
            .padding(.horizontal, 8)

            Spacer()

            Button(action: onDismiss) {
                Text("Got it!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.Colors.accent)
                    .cornerRadius(16)
            }
            .padding(.bottom, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

struct TutorialRow: View {

    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 44, height: 44)
                .background(Theme.Colors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)

                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}
