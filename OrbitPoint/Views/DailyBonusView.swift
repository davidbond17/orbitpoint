import SwiftUI

struct DailyBonusView: View {

    @ObservedObject private var bonusManager = DailyBonusManager.shared
    @Binding var isPresented: Bool
    @State private var claimed = false
    @State private var claimedAmount = 0
    @State private var scale: CGFloat = 0.8
    @State private var coinScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    if claimed { isPresented = false }
                }

            VStack(spacing: 24) {
                Text(claimed ? "Bonus Claimed!" : "Daily Bonus")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)

                    Image(systemName: "circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(coinScale)
                        .animation(
                            claimed
                                ? .spring(response: 0.4, dampingFraction: 0.5).repeatCount(1)
                                : .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                            value: coinScale
                        )
                }
                .onAppear {
                    coinScale = claimed ? 1.3 : 1.05
                }

                VStack(spacing: 6) {
                    if claimed {
                        Text("+\(claimedAmount)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("coins added to your balance")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary)
                    } else {
                        Text("\(bonusManager.currentBonusAmount) coins")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("Day \(bonusManager.streak + 1) streak")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }

                if claimed {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Continue")
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal, 40)
                } else {
                    Button {
                        claimedAmount = bonusManager.claimBonus()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            claimed = true
                            coinScale = 1.3
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "gift.fill")
                            Text("Claim Bonus")
                        }
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal, 40)
                }
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(32)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                }
                coinScale = 1.05
            }
        }
    }
}
