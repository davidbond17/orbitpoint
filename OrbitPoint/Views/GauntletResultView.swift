import SwiftUI

struct GauntletResultView: View {

    let rounds: Int
    let totalTime: Int
    let coinsEarned: Int
    let xpEarned: Int
    let didLevelUp: Bool
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @State private var showContent = false
    @State private var showShare = false
    @State private var showChallenge = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("SURVIVAL GAUNTLET")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .opacity(showContent ? 1 : 0)

                VStack(spacing: 4) {
                    Text("\(rounds)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)

                    Text(rounds == 1 ? "round survived" : "rounds survived")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .opacity(showContent ? 1 : 0)
                }

                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Time")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("\(totalTime)s")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }

                    Rectangle()
                        .fill(Theme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 1, height: 30)

                    VStack(spacing: 4) {
                        Text("Best")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("\(ScoreManager.shared.gauntletBestRounds)R")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                }
                .opacity(showContent ? 1 : 0)

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
                    Text("\(coinsEarned)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(.top, 4)
                .opacity(showContent ? 1 : 0)

                XPEarnedRow(xpEarned: xpEarned, didLevelUp: didLevelUp)
                    .opacity(showContent ? 1 : 0)
            }
            .padding(32)
            .glassBackground()

            Spacer()

            VStack(spacing: 16) {
                Button(action: onPlayAgain) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                }
                .buttonStyle(.glass)

                Button(action: onMenu) {
                    HStack(spacing: 12) {
                        Image(systemName: "house.fill")
                        Text("Menu")
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                .buttonStyle(.glass)

                HStack(spacing: 16) {
                    Button {
                        showShare = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                    }

                    Button {
                        showChallenge = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                            Text("Challenge")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.orange)
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
            if let image = ScoreCardRenderer.render(score: rounds, mode: "Gauntlet", isHighScore: false) {
                ShareSheet(items: [image])
            }
        }
        .sheet(isPresented: $showChallenge) {
            ShareSheet(items: challengeItems)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }

    private var challengeItems: [Any] {
        var items: [Any] = [DeepLinkManager.shareText(score: rounds, mode: "Gauntlet")]
        if let image = ScoreCardRenderer.render(score: rounds, mode: "Gauntlet", isHighScore: false) {
            items.append(image)
        }
        if let url = DeepLinkManager.challengeURL(score: rounds, mode: "Gauntlet") {
            items.append(url)
        }
        return items
    }
}
