import SwiftUI

struct ScoreCardView: View {

    let score: Int
    let mode: String
    let isHighScore: Bool

    private var progression: PlayerProgressionManager { PlayerProgressionManager.shared }

    var body: some View {
        VStack(spacing: 16) {
            Text("ORBIT POINT")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.4, green: 0.8, blue: 1.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("\(score)")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text(mode)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white.opacity(0.7))

            if isHighScore {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("New High Score!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
            }

            HStack(spacing: 4) {
                Text("Lv.\(progression.currentLevel)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                Text(progression.levelTitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
            }
        }
        .padding(32)
        .frame(width: 300)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.16), Color(red: 0.04, green: 0.04, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
    }
}

enum ScoreCardRenderer {

    @MainActor
    static func render(score: Int, mode: String, isHighScore: Bool) -> UIImage? {
        let view = ScoreCardView(score: score, mode: mode, isHighScore: isHighScore)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}
