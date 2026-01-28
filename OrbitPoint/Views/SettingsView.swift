import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var musicVolume: Float = MusicManager.shared.volume

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Theme.Colors.glassBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)

            VStack(spacing: 16) {
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound",
                    isOn: $viewModel.soundEnabled
                )

                SettingsRow(
                    icon: "hand.tap.fill",
                    title: "Haptics",
                    isOn: $viewModel.hapticsEnabled
                )

                MusicVolumeRow(volume: $musicVolume)
                    .onChange(of: musicVolume) { _, newValue in
                        MusicManager.shared.setVolume(newValue)
                    }

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.showHowToPlay = true
                    }
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.Colors.accent)
                            .frame(width: 32)

                        Text("How to Play")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .glassBackground()
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Text("Credits")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)

                Link(destination: URL(string: "https://uppbeat.io/t/danijel-zambo/trap")!) {
                    HStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .font(.system(size: 12))
                        Text("Music by Danijel Zambo via Uppbeat")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Theme.Colors.accent)
                }

                Text("OrbitPoint v1.0")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

struct SettingsRow: View {

    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 32)

            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Theme.Colors.accent)
                .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassBackground()
    }
}

struct MusicVolumeRow: View {

    @Binding var volume: Float

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "music.note")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 32)

            Text("Music")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer()

            Slider(value: $volume, in: 0...1)
                .tint(Theme.Colors.accent)
                .frame(width: 100)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassBackground()
    }
}
