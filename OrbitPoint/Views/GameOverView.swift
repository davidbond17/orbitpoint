import SwiftUI

struct GameOverView: View {

    let score: Int
    let isNewHighScore: Bool
    let highScore: Int
    let onPlayAgain: () -> Void
    let onMenu: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                if isNewHighScore {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("New High Score!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                }

                Text("\(score)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.accent, Theme.Colors.satellite],
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

                if !isNewHighScore {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow.opacity(0.7))
                            .font(.system(size: 14))
                        Text("Best: \(highScore)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, 8)
                    .opacity(showContent ? 1 : 0)
                }
            }
            .padding(40)
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
