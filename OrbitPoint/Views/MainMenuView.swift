import SwiftUI

struct MainMenuView: View {

    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var bonusManager = DailyBonusManager.shared
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if bonusManager.bonusAvailable {
                    Button {
                        viewModel.showDailyBonus = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                            Text("Daily Bonus!")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassBackground()
                    }
                }
                Spacer()
                CoinDisplay(amount: viewModel.totalCurrency)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            VStack(spacing: 16) {
                Text("ORBIT")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.accent, Theme.Colors.satellite],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("POINT")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .offset(y: -10)
            }
            .padding(.top, 40)

            Spacer()

            VStack(spacing: 16) {
                if viewModel.highScore > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Best: \(viewModel.highScore)")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.bottom, 8)
                }

                Button(action: onPlay) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                        Text("Free Play")
                    }
                }
                .buttonStyle(.glass)
                .padding(.horizontal, 40)

                Button {
                    viewModel.showCampaignMap()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "map.fill")
                        Text("Campaign")
                    }
                }
                .buttonStyle(.glass)
                .padding(.horizontal, 40)

                HStack(spacing: 10) {
                    ModeCard(icon: "leaf.fill", title: "Zen", color: .green) {
                        viewModel.startZenMode()
                    }
                    ModeCard(icon: "bolt.fill", title: "Gauntlet", color: .orange) {
                        viewModel.startGauntlet()
                    }
                    ModeCard(icon: "timer", title: "Time Attack", color: .red) {
                        viewModel.startTimeAttack()
                    }
                }
                .padding(.horizontal, 40)

                HStack(spacing: 12) {
                    Button {
                        viewModel.showStore = true
                    } label: {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 50, height: 50)
                    }
                    .glassBackground()

                    Button {
                        viewModel.replayLoreIntro()
                    } label: {
                        Image(systemName: "film.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 50, height: 50)
                    }
                    .glassBackground()

                    Button {
                        viewModel.showCodex = true
                    } label: {
                        Image(systemName: "book.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 50, height: 50)
                    }
                    .glassBackground()

                    Button {
                        viewModel.showLeaderboard = true
                    } label: {
                        Image(systemName: "trophy")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 50, height: 50)
                    }
                    .glassBackground()

                    Button {
                        viewModel.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 50, height: 50)
                    }
                    .glassBackground()
                }
                .foregroundColor(Theme.Colors.textPrimary)
            }
            .padding(.bottom, 120)

            VStack(spacing: 4) {
                Text("Tap to reverse orbit")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.6))
                Text("Swipe up/down to switch orbits")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.4))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ModeCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .glassBackground()
        }
    }
}

struct CoinDisplay: View {
    let amount: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("\(amount)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassBackground()
    }
}
