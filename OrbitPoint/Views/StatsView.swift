import SwiftUI

struct StatsView: View {

    @Environment(\.dismiss) private var dismiss
    private let stats = ScoreManager.shared

    @State private var selectedTab: StatsTab = .overview

    private enum StatsTab: String, CaseIterable {
        case overview = "Overview"
        case freePlay = "Free Play"
        case campaign = "Campaign"
        case modes = "Modes"
    }

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
            .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(StatsTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedTab == tab ? .white : Theme.Colors.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedTab == tab ? Theme.Colors.accent : Theme.Colors.glassBackground)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 12) {
                    switch selectedTab {
                    case .overview:
                        overviewSection
                    case .freePlay:
                        freePlaySection
                    case .campaign:
                        campaignSection
                    case .modes:
                        modesSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private var overviewSection: some View {
        Group {
            let progression = PlayerProgressionManager.shared
            StatCard(icon: "star.circle.fill", iconColor: .cyan, title: "Player Level",
                     value: "Lv.\(progression.currentLevel) \(progression.levelTitle)")
            StatCard(icon: "sparkles", iconColor: .cyan, title: "Total XP",
                     value: "\(progression.totalXP)")
            StatCard(icon: "trophy.fill", iconColor: .yellow, title: "Best Score",
                     value: "\(stats.highScore)s")
            StatCard(icon: "gamecontroller.fill", iconColor: Theme.Colors.accent, title: "Games Played",
                     value: "\(stats.totalGamesPlayed)")
            StatCard(icon: "clock.fill", iconColor: .green, title: "Total Time Survived",
                     value: formattedTime(stats.totalTimeSurvived))
            StatCard(icon: "chart.line.uptrend.xyaxis", iconColor: .purple, title: "Average Score",
                     value: averageScore)
            StatCard(icon: "circle.fill", iconColor: .orange, title: "Total Coins Earned",
                     value: "\(stats.totalCoinsEarned)")
            StatCard(icon: "bag.fill", iconColor: Color(red: 1.0, green: 0.4, blue: 0.7), title: "Total Coins Spent",
                     value: "\(stats.totalCoinsSpent)")
            StatCard(icon: "cart.fill", iconColor: Color(red: 0.4, green: 0.8, blue: 0.4), title: "Items Purchased",
                     value: "\(stats.purchaseCount)")
        }
    }

    private var freePlaySection: some View {
        Group {
            StatCard(icon: "gamecontroller.fill", iconColor: Theme.Colors.accent, title: "Games Played",
                     value: "\(stats.freePlayGamesPlayed)")
            StatCard(icon: "trophy.fill", iconColor: .yellow, title: "High Score",
                     value: "\(stats.highScore)s")
            StatCard(icon: "chart.line.uptrend.xyaxis", iconColor: .purple, title: "Average Score",
                     value: averageScore)
            StatCard(icon: "timer", iconColor: .red, title: "Longest Survival",
                     value: "\(stats.longestSurvival)s")
        }
    }

    private var campaignSection: some View {
        Group {
            let campaign = CampaignManager.shared
            StatCard(icon: "star.fill", iconColor: .yellow, title: "Total Stars",
                     value: "\(campaign.totalStars)")
            StatCard(icon: "map.fill", iconColor: .green, title: "Zones Completed",
                     value: "\(zonesCompleted)")
            StatCard(icon: "flag.fill", iconColor: Theme.Colors.accent, title: "Levels Completed",
                     value: "\(campaign.completedLevels.count)")
        }
    }

    private var modesSection: some View {
        Group {
            StatCard(icon: "bolt.fill", iconColor: .orange, title: "Gauntlet Best Rounds",
                     value: "\(stats.gauntletBestRounds)")
            StatCard(icon: "bolt.fill", iconColor: .orange, title: "Gauntlet Best Time",
                     value: "\(stats.gauntletBestTime)s")
            StatCard(icon: "timer", iconColor: .red, title: "Time Attack Best",
                     value: "\(stats.timeAttackBestTime)s")
            StatCard(icon: "calendar.badge.clock", iconColor: .blue, title: "Daily Games Played",
                     value: "\(stats.dailyChallengeGamesPlayed)")
            StatCard(icon: "flame.fill", iconColor: .orange, title: "Daily Best Streak",
                     value: "\(stats.dailyChallengeBestStreak)")
            StatCard(icon: "leaf.fill", iconColor: .green, title: "Zen Total Time",
                     value: formattedTime(stats.zenTotalTime))
        }
    }

    private var zonesCompleted: Int {
        let campaign = CampaignManager.shared
        var count = 0
        for zone in 1...5 {
            let progress = campaign.zoneProgress(zone)
            if progress >= 1.0 {
                count += 1
            }
        }
        return count
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
