import SwiftUI

struct LeaderboardView: View {

    @Environment(\.dismiss) private var dismiss

    let highScore: Int
    let onShowGameCenter: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Leaderboard")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.glassBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)

            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)

                    Text("Your Best")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text("\(highScore)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.Colors.accent, Theme.Colors.satellite],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("seconds")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.7))
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .glassBackground()

                Button(action: onShowGameCenter) {
                    HStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                        Text("Game Center")
                    }
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}
