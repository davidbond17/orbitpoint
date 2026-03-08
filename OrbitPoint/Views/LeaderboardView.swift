import SwiftUI
import GameKit

struct LeaderboardView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var gcManager = GameCenterManager.shared

    let highScore: Int
    let onShowGameCenter: () -> Void

    @State private var selectedMode = "Free Play"
    @State private var selectedScope: GKLeaderboard.PlayerScope = .global
    @State private var entries: [GameCenterManager.LeaderboardEntry] = []
    @State private var isLoading = false

    private let modes = ["Free Play", "Gauntlet", "Time Attack", "Daily"]

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(modes, id: \.self) { mode in
                        Button {
                            selectedMode = mode
                            loadEntries()
                        } label: {
                            Text(mode)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedMode == mode ? .white : Theme.Colors.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedMode == mode ? Theme.Colors.accent : Theme.Colors.glassBackground)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                scopeButton(title: "Global", scope: .global)
                scopeButton(title: "Friends", scope: .friendsOnly)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            if !gcManager.isAuthenticated {
                unauthenticatedView
            } else if isLoading {
                Spacer()
                ProgressView()
                    .tint(Theme.Colors.textSecondary)
                Spacer()
            } else if entries.isEmpty {
                Spacer()
                Text("No entries yet")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(entries) { entry in
                            entryRow(entry)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }

            Button(action: onShowGameCenter) {
                HStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                    Text("Game Center")
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear {
            loadEntries()
        }
    }

    private var header: some View {
        HStack {
            Text("Leaderboard")
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
        .padding(.bottom, 16)
    }

    private func scopeButton(title: String, scope: GKLeaderboard.PlayerScope) -> some View {
        Button {
            selectedScope = scope
            loadEntries()
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(selectedScope == scope ? Theme.Colors.textPrimary : Theme.Colors.textSecondary.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedScope == scope ? Theme.Colors.glassBackground : Color.clear)
                .cornerRadius(12)
        }
    }

    private func entryRow(_ entry: GameCenterManager.LeaderboardEntry) -> some View {
        HStack(spacing: 12) {
            Text("#\(entry.rank)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(rankColor(entry.rank))
                .frame(width: 40, alignment: .leading)

            Text(entry.playerName)
                .font(.system(size: 15, weight: entry.isLocalPlayer ? .bold : .medium, design: .rounded))
                .foregroundColor(entry.isLocalPlayer ? Theme.Colors.accent : Theme.Colors.textPrimary)
                .lineLimit(1)

            Spacer()

            Text("\(entry.score)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(entry.isLocalPlayer ? Theme.Colors.accent : Theme.Colors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(entry.isLocalPlayer ? Theme.Colors.accent.opacity(0.1) : Color.clear)
        .glassBackground()
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return Theme.Colors.textSecondary
        }
    }

    private var unauthenticatedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "gamecontroller")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            Text("Sign in to Game Center\nto see leaderboards")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private func loadEntries() {
        guard gcManager.isAuthenticated else { return }
        isLoading = true
        let leaderboardID = gcManager.leaderboardID(for: selectedMode)
        let scope = selectedScope
        Task {
            let result = await gcManager.loadLeaderboardEntries(leaderboardID: leaderboardID, scope: scope)
            entries = result
            isLoading = false
        }
    }
}
