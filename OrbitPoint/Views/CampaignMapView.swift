import SwiftUI

struct CampaignMapView: View {

    @ObservedObject var viewModel: GameViewModel
    @StateObject private var campaignManager = CampaignManager.shared

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(CampaignLevels.allZones, id: \.self) { zone in
                        ZoneCard(
                            zone: zone,
                            viewModel: viewModel,
                            campaignManager: campaignManager
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    viewModel.returnToMenu()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    Text("\(campaignManager.totalStars)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassBackground()

                CoinDisplay(amount: viewModel.totalCurrency)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Text("CAMPAIGN")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.accent, Theme.Colors.satellite],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 8)
        }
    }
}

struct ZoneCard: View {

    let zone: Int
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var campaignManager: CampaignManager
    @State private var showBriefing = false
    @State private var pendingLevel: Int?

    private var theme: ZoneTheme {
        ZoneThemes.theme(for: zone)
    }

    private var isUnlocked: Bool {
        campaignManager.isZoneUnlocked(zone)
    }

    private var levels: [LevelConfig] {
        CampaignLevels.levels(for: zone)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                zoneHeader
                if isUnlocked {
                    levelGrid
                } else {
                    lockedOverlay
                }
            }
            .padding(20)
            .glassBackground()
            .opacity(isUnlocked ? 1.0 : 0.6)

            if showBriefing {
                MissionBriefingView(zone: zone) {
                    campaignManager.markBriefingSeen(for: zone)
                    showBriefing = false
                    if let level = pendingLevel {
                        pendingLevel = nil
                        viewModel.startCampaignLevel(zone: zone, level: level)
                    }
                }
                .transition(.opacity)
            }
        }
    }

    private var zoneHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: theme.iconName)
                .font(.system(size: 24))
                .foregroundColor(isUnlocked ? theme.accentColor : Theme.Colors.textSecondary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isUnlocked ? theme.accentColor.opacity(0.15) : Theme.Colors.glassBackground)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Zone \(zone): \(theme.name)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.textPrimary)

                Text(theme.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    Text("\(campaignManager.starsForZone(zone))/\(campaignManager.maxStarsForZone(zone))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                zoneProgressBar
            }
        }
    }

    private var zoneProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.Colors.glassBackground)
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(isUnlocked ? theme.accentColor : Theme.Colors.textSecondary)
                    .frame(width: geo.size.width * campaignManager.zoneProgress(zone), height: 4)
            }
        }
        .frame(width: 60, height: 4)
    }

    private var levelGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
            ForEach(levels) { level in
                LevelButton(
                    level: level,
                    isUnlocked: campaignManager.isLevelUnlocked(zone: zone, level: level.level),
                    stars: campaignManager.starsForLevel(zone: zone, level: level.level),
                    accentColor: theme.accentColor
                ) {
                    startLevel(level.level)
                }
            }
        }
    }

    private func startLevel(_ level: Int) {
        if campaignManager.shouldShowBriefing(for: zone) {
            pendingLevel = level
            withAnimation(.easeIn(duration: 0.3)) {
                showBriefing = true
            }
        } else {
            viewModel.startCampaignLevel(zone: zone, level: level)
        }
    }

    private var lockedOverlay: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .foregroundColor(Theme.Colors.textSecondary)
            Text("Requires \(theme.requiredStars) stars")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.vertical, 16)
    }
}

struct LevelButton: View {

    let level: LevelConfig
    let isUnlocked: Bool
    let stars: Int
    let accentColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(level.level)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isUnlocked ? Theme.Colors.textPrimary : Theme.Colors.textSecondary.opacity(0.5))

                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { star in
                        Image(systemName: star <= stars ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundColor(star <= stars ? .yellow : Theme.Colors.textSecondary.opacity(0.3))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? accentColor.opacity(0.1) : Theme.Colors.glassBackground.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                stars == 3 ? Color.yellow.opacity(0.4) : Theme.Colors.glassBorder,
                                lineWidth: 1
                            )
                    )
            )
        }
        .disabled(!isUnlocked)
    }
}
