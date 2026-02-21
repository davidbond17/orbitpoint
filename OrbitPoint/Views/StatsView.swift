import SwiftUI

struct StatsView: View {

    @Environment(\.dismiss) private var dismiss
    private let stats = ScoreManager.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Your Stats")
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

            ScrollView {
                VStack(spacing: 12) {
                    StatCard(
                        icon: "trophy.fill",
                        iconColor: .yellow,
                        title: "Best Score",
                        value: "\(stats.highScore)s"
                    )

                    StatCard(
                        icon: "gamecontroller.fill",
                        iconColor: Theme.Colors.accent,
                        title: "Games Played",
                        value: "\(stats.totalGamesPlayed)"
                    )

                    StatCard(
                        icon: "clock.fill",
                        iconColor: .green,
                        title: "Total Time Survived",
                        value: formattedTime(stats.totalTimeSurvived)
                    )

                    StatCard(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .purple,
                        title: "Average Score",
                        value: averageScore
                    )

                    StatCard(
                        icon: "circle.fill",
                        iconColor: .orange,
                        title: "Total Coins Earned",
                        value: "\(stats.totalCoinsEarned)"
                    )

                    StatCard(
                        icon: "bag.fill",
                        iconColor: Color(red: 1.0, green: 0.4, blue: 0.7),
                        title: "Total Coins Spent",
                        value: "\(stats.totalCoinsSpent)"
                    )

                    StatCard(
                        icon: "cart.fill",
                        iconColor: Color(red: 0.4, green: 0.8, blue: 0.4),
                        title: "Items Purchased",
                        value: "\(stats.purchaseCount)"
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private var averageScore: String {
        guard stats.totalGamesPlayed > 0 else { return "0s" }
        return "\(stats.totalTimeSurvived / stats.totalGamesPlayed)s"
    }

    private func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(secs)s"
        } else {
            return "\(secs)s"
        }
    }
}

struct StatCard: View {

    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32)

            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.accent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassBackground()
    }
}
