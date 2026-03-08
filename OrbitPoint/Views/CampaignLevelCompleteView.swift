import SwiftUI

struct CampaignLevelCompleteView: View {

    let result: LevelResult
    let xpEarned: Int
    let didLevelUp: Bool
    let onNextLevel: () -> Void
    let onRetry: () -> Void
    let onMap: () -> Void

    @State private var showContent = false
    @State private var showShare = false

    private var passed: Bool { result.passed }
    private var stars: Int { result.starsEarned }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text(passed ? "Level Complete!" : "Level Failed")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(passed ? .green : Theme.Colors.textSecondary)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                Text(result.levelConfig.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .opacity(showContent ? 1 : 0)

                if passed {
                    starDisplay
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                }

                timeDisplay
                    .opacity(showContent ? 1 : 0)

                if passed && result.earnedCoins > 0 {
                    coinDisplay
                        .opacity(showContent ? 1 : 0)
                }

                if let bonus = result.levelConfig.bonusObjective {
                    bonusDisplay(bonus: bonus)
                        .opacity(showContent ? 1 : 0)
                }

                XPEarnedRow(xpEarned: xpEarned, didLevelUp: didLevelUp)
                    .opacity(showContent ? 1 : 0)
            }
            .padding(40)
            .glassBackground()

            Spacer()

            VStack(spacing: 16) {
                if passed {
                    let nextExists = CampaignLevels.level(
                        zone: result.levelConfig.zone,
                        level: result.levelConfig.level + 1
                    ) != nil

                    if nextExists {
                        Button(action: onNextLevel) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right")
                                Text("Next Level")
                            }
                        }
                        .buttonStyle(.glass)
                    }
                }

                Button(action: onRetry) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                        Text(passed ? "Retry for Stars" : "Try Again")
                    }
                    .foregroundColor(passed ? Theme.Colors.textSecondary : Theme.Colors.textPrimary)
                }
                .buttonStyle(.glass)

                Button(action: onMap) {
                    HStack(spacing: 12) {
                        Image(systemName: "map.fill")
                        Text("Campaign Map")
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                .buttonStyle(.glass)

                if passed {
                    Button {
                        showShare = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 40)
            .offset(y: showContent ? 0 : 50)
            .opacity(showContent ? 1 : 0)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showShare) {
            if let image = ScoreCardRenderer.render(score: Int(result.survivalTime), mode: "Campaign", isHighScore: false) {
                ShareSheet(items: [image])
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
            if passed, let lineId = VoiceLineManager.shared.randomCompleteLine() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    VoiceLineManager.shared.play(lineId)
                }
            } else if !passed, let lineId = VoiceLineManager.shared.randomGameOverLine() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    VoiceLineManager.shared.play(lineId)
                }
            }
        }
    }

    private var starDisplay: some View {
        HStack(spacing: 12) {
            ForEach(1...3, id: \.self) { star in
                Image(systemName: star <= stars ? "star.fill" : "star")
                    .font(.system(size: 32))
                    .foregroundColor(star <= stars ? .yellow : Theme.Colors.textSecondary.opacity(0.3))
            }
        }
    }

    private var timeDisplay: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1fs", result.survivalTime))
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.accent, Theme.Colors.satellite],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            HStack(spacing: 16) {
                Text("Target: \(Int(result.levelConfig.targetTime))s")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(passed ? .green : Theme.Colors.textSecondary)

                if passed {
                    Text("3-star: \(Int(result.levelConfig.threeStarTime))s")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(stars >= 3 ? .yellow : Theme.Colors.textSecondary.opacity(0.5))
                }
            }
        }
    }

    private var coinDisplay: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.green)

            Image(systemName: "circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("\(result.earnedCoins)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }

    private func bonusDisplay(bonus: BonusObjective) -> some View {
        HStack(spacing: 8) {
            Image(systemName: result.bonusCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(result.bonusCompleted ? .green : Theme.Colors.textSecondary.opacity(0.5))
                .font(.system(size: 16))

            Text(bonus.description)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(result.bonusCompleted ? Theme.Colors.textPrimary : Theme.Colors.textSecondary.opacity(0.5))
        }
        .padding(.top, 4)
    }
}
