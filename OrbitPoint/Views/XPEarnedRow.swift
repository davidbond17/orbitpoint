import SwiftUI

struct XPEarnedRow: View {

    let xpEarned: Int
    let didLevelUp: Bool

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.cyan)

                Text("\(xpEarned) XP")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
            }

            if didLevelUp {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    Text("Level Up! \(PlayerProgressionManager.shared.levelTitle) Lv.\(PlayerProgressionManager.shared.currentLevel)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}
