import SwiftUI

struct CodexView: View {

    @StateObject private var loreManager = LoreManager.shared
    @Environment(\.dismiss) private var dismiss
    var onReplayIntro: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    missionBriefingCard
                    progressHeader

                    ForEach(CampaignLevels.allZones, id: \.self) { zone in
                        zoneSection(zone: zone)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Codex")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.Colors.accent)
                }
            }
        }
    }

    private var missionBriefingCard: some View {
        Button {
            dismiss()
            onReplayIntro?()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.accent, Color(red: 1.0, green: 0.6, blue: 0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("Mission Briefing")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text("Replay the intro sequence")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            }
            .padding(14)
            .glassBackground()
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "diamond.fill")
                    .foregroundColor(Color(red: 0.3, green: 0.9, blue: 1.0))
                Text("\(loreManager.totalCollected) / \(loreManager.totalAvailable)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)
            }

            Text("Data Crystals Recovered")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textSecondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.glassBackground)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.3, green: 0.9, blue: 1.0))
                        .frame(
                            width: geo.size.width * (loreManager.totalAvailable > 0
                                ? CGFloat(loreManager.totalCollected) / CGFloat(loreManager.totalAvailable)
                                : 0),
                            height: 6
                        )
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private func zoneSection(zone: Int) -> some View {
        let fragments = LoreFragments.fragments(for: zone)
        let theme = ZoneThemes.theme(for: zone)

        if !fragments.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: theme.iconName)
                        .foregroundColor(theme.accentColor)
                        .font(.system(size: 16))

                    Text(theme.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)

                    Spacer()

                    let collected = fragments.filter { loreManager.isCollected($0.id) }.count
                    Text("\(collected)/\(fragments.count)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                ForEach(fragments) { fragment in
                    fragmentCard(fragment: fragment)
                }
            }
        }
    }

    private func fragmentCard(fragment: LoreFragment) -> some View {
        let collected = loreManager.isCollected(fragment.id)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: collected ? "diamond.fill" : "diamond")
                    .foregroundColor(collected
                        ? Color(red: 0.3, green: 0.9, blue: 1.0)
                        : Theme.Colors.textSecondary.opacity(0.4))
                    .font(.system(size: 12))

                Text(collected ? fragment.title : "???")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(collected ? Theme.Colors.textPrimary : Theme.Colors.textSecondary.opacity(0.4))

                Spacer()

                Text("Level \(fragment.level)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            }

            if collected {
                Text(fragment.text)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(14)
        .glassBackground()
        .opacity(collected ? 1.0 : 0.5)
    }
}
