import SwiftUI

struct MusicCredit: Identifiable {
    let id = UUID()
    let trackName: String
    let artist: String
    let source: String
    let url: String
    let licenseCode: String?
}

struct MusicCreditsView: View {

    @Environment(\.dismiss) private var dismiss

    private let credits: [MusicCredit] = [
        MusicCredit(
            trackName: "Trap",
            artist: "Danijel Zambo",
            source: "Uppbeat",
            url: "https://uppbeat.io/t/danijel-zambo/trap",
            licenseCode: nil
        ),
        MusicCredit(
            trackName: "Space Ranger",
            artist: "Moire",
            source: "Uppbeat",
            url: "https://uppbeat.io/t/moire/space-ranger",
            licenseCode: "Z2Z9E8YUSDU2E4PP"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
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
            .padding(.top, 20)

            VStack(spacing: 8) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 36))
                    .foregroundColor(Theme.Colors.accent)

                Text("Music Credits")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("Licensed via Uppbeat")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)

            VStack(spacing: 12) {
                ForEach(credits) { credit in
                    creditCard(credit: credit)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Link(destination: URL(string: "https://uppbeat.io")!) {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 14))
                    Text("Browse more on Uppbeat")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Theme.Colors.accent)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .glassBackground()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private func creditCard(credit: MusicCredit) -> some View {
        Link(destination: URL(string: credit.url)!) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.accent.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "music.note")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(credit.trackName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text("by \(credit.artist)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)

                    if let code = credit.licenseCode {
                        Text("License: \(code)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                    }
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            }
            .padding(16)
            .glassBackground()
        }
    }
}
