import SwiftUI

struct LoreIntroView: View {

    let onComplete: () -> Void

    @State private var currentCard = 0
    @State private var textOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var showSkip = false

    private let cards: [(title: String?, body: String, voiceId: String)] = [
        (nil, "The year is 3847.", "intro_1"),
        (nil, "Humanity's last star is dying.", "intro_2"),
        (nil, "A network of orbital satellites maintains its containment field — keeping it stable, keeping it alive.", "intro_3"),
        (nil, "One by one, the probes have fallen.\nDestroyed by debris. Lost to the void.", "intro_4"),
        ("YOU ARE OP-1", "The last autonomous probe.\nYour mission: stay in orbit.\nEvery second you hold delays the inevitable.", "intro_5"),
        (nil, "Tap to reverse direction.\nAvoid the debris.\nMake it count.", "intro_6")
    ]

    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            starfield

            VStack(spacing: 24) {
                Spacer()

                if let title = cards[currentCard].title {
                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.Colors.accent, Theme.Colors.starGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .opacity(subtitleOpacity)
                }

                Text(cards[currentCard].body)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)

                Spacer()

                if currentCard < cards.count - 1 {
                    Text("TAP TO CONTINUE")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.6))
                        .tracking(2)
                        .opacity(textOpacity)
                } else {
                    Button {
                        VoiceLineManager.shared.stop()
                        onComplete()
                    } label: {
                        Text("BEGIN MISSION")
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)
                }

                if showSkip && currentCard < cards.count - 1 {
                    Button {
                        VoiceLineManager.shared.stop()
                        onComplete()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                    }
                }

                Spacer()
                    .frame(height: 40)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if currentCard < cards.count - 1 {
                advanceCard()
            }
        }
        .onAppear {
            fadeIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showSkip = true
                }
            }
        }
    }

    private var starfield: some View {
        Canvas { context, size in
            let seed: UInt64 = 42
            var rng = SeededRNG(seed: seed)
            for _ in 0..<80 {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let radius = CGFloat.random(in: 0.5...1.5, using: &rng)
                let opacity = Double.random(in: 0.2...0.7, using: &rng)
                context.opacity = opacity
                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.white))
            }
        }
        .ignoresSafeArea()
    }

    private func fadeIn() {
        withAnimation(.easeIn(duration: 1.0)) {
            textOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 1.0).delay(0.3)) {
            subtitleOpacity = 1.0
        }
        VoiceLineManager.shared.play(cards[currentCard].voiceId)
    }

    private func advanceCard() {
        withAnimation(.easeOut(duration: 0.3)) {
            textOpacity = 0
            subtitleOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentCard += 1
            fadeIn()
        }
    }
}

private struct SeededRNG: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
