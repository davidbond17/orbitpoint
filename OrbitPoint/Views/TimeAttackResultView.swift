import SwiftUI

struct TimeAttackResultView: View {

    let timeSurvived: Int
    let completed: Bool
    let coinsEarned: Int
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("TIME ATTACK")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .opacity(showContent ? 1 : 0)

                Text(completed ? "SURVIVED!" : "FAILED")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(completed ? .green : .red)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(timeSurvived)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: completed
                                    ? [Color.green, Color.mint]
                                    : [Theme.Colors.accent, Theme.Colors.satellite],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("/ 60s")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 4) {
                    Text("Best")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("\(ScoreManager.shared.timeAttackBestTime)s")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
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
