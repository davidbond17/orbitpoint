import SwiftUI

struct DailyChallengeResultView: View {

    let score: Int
    let targetTime: Int
    let todaysBest: Int
    let streak: Int
    let coinsEarned: Int
    let hasCompletedToday: Bool
    let onTryAgain: () -> Void
    let onMenu: () -> Void

    @State private var showContent = false

    private var passedTarget: Bool {
        score >= targetTime
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("DAILY CHALLENGE")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .opacity(showContent ? 1 : 0)

                Text("\(score)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: passedTarget
                                ? [Color.green, Color.mint]
                                : [Theme.Colors.accent, Theme.Colors.satellite],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)

                Text("seconds survived")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .opacity(showContent ? 1 : 0)

                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("Target")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                        HStack(spacing: 4) {
                            Image(systemName: passedTarget ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passedTarget ? .green : .red)
                                .font(.system(size: 14))
                            Text("\(targetTime)s")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }

                    Rectangle()
                        .fill(Theme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 1, height: 30)

                    VStack(spacing: 4) {
                        Text("Best Today")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Text("\(todaysBest)s")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                }
                .opacity(showContent ? 1 : 0)

                if streak > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))
                        Text("\(streak) day streak")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .opacity(showContent ? 1 : 0)
                }

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
            }
            .padding(32)
            .glassBackground()

            Spacer()

            VStack(spacing: 16) {
                Button(action: onTryAgain) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Try Again")
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
            }
            .padding(.horizontal, 40)
            .offset(y: showContent ? 0 : 50)
            .opacity(showContent ? 1 : 0)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
}
