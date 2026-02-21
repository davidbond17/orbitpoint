import GameKit
import SwiftUI

@MainActor
class GameCenterManager: ObservableObject {

    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?

    private let leaderboardID = "com.davidbond.orbitpoint.leaderboard"

    enum Achievement: String {
        case firstOrbit      = "com.davidbond.orbitpoint.first_orbit"
        case asteroidDodger  = "com.davidbond.orbitpoint.asteroid_dodger"
        case spaceVeteran    = "com.davidbond.orbitpoint.space_veteran"
        case orbitalMaster   = "com.davidbond.orbitpoint.orbital_master"
        case firstPurchase   = "com.davidbond.orbitpoint.first_purchase"
        case collector       = "com.davidbond.orbitpoint.collector"
        case coinHoarder     = "com.davidbond.orbitpoint.coin_hoarder"
        case bigSpender      = "com.davidbond.orbitpoint.big_spender"
        case frequentFlyer   = "com.davidbond.orbitpoint.frequent_flyer"
        case dedicatedPilot  = "com.davidbond.orbitpoint.dedicated_pilot"
    }

    private init() {}

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let error = error {
                    print("Game Center authentication failed: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    return
                }

                if let vc = viewController {
                    self?.presentAuthViewController(vc)
                    return
                }

                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    self?.localPlayer = GKLocalPlayer.local
                    self?.configureAccessPoint()
                    print("Game Center authenticated successfully")
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
    }

    private func presentAuthViewController(_ viewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        var presenter = rootViewController
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        presenter.present(viewController, animated: true)
    }

    private func configureAccessPoint() {
        GKAccessPoint.shared.location = .topLeading
        GKAccessPoint.shared.showHighlights = true
        GKAccessPoint.shared.isActive = false
    }

    func showAccessPoint(_ show: Bool) {
        GKAccessPoint.shared.isActive = show && isAuthenticated
    }

    func submitScore(_ score: Int) async {
        guard isAuthenticated else {
            print("Cannot submit score: Not authenticated with Game Center")
            return
        }

        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboardID]
            )
            print("Score submitted to Game Center: \(score)")
        } catch {
            print("Failed to submit score: \(error.localizedDescription)")
        }
    }

    func showLeaderboard() {
        guard isAuthenticated else {
            print("Cannot show leaderboard: Not authenticated with Game Center")
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let gcViewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        gcViewController.gameCenterDelegate = GameCenterDismissHandler.shared

        var presenter = rootViewController
        while let presented = presenter.presentedViewController {
            presenter = presented
        }

        presenter.present(gcViewController, animated: true)
    }

    func reportAchievementsAfterGame(score: Int) async {
        guard isAuthenticated else { return }
        let stats = ScoreManager.shared
        var toReport: [Achievement] = []

        if score >= 10  { toReport.append(.firstOrbit) }
        if score >= 30  { toReport.append(.asteroidDodger) }
        if score >= 60  { toReport.append(.spaceVeteran) }
        if score >= 120 { toReport.append(.orbitalMaster) }
        if stats.totalGamesPlayed >= 10 { toReport.append(.frequentFlyer) }
        if stats.totalGamesPlayed >= 25 { toReport.append(.dedicatedPilot) }
        if stats.totalCoinsEarned >= 500 { toReport.append(.coinHoarder) }

        await reportAchievements(toReport)
    }

    func reportAchievementsAfterPurchase() async {
        guard isAuthenticated else { return }
        let stats = ScoreManager.shared
        var toReport: [Achievement] = []

        if stats.purchaseCount >= 1 { toReport.append(.firstPurchase) }
        if stats.purchaseCount >= 5 { toReport.append(.collector) }
        if stats.totalCoinsSpent >= 500 { toReport.append(.bigSpender) }

        await reportAchievements(toReport)
    }

    private func reportAchievements(_ achievements: [Achievement]) async {
        guard !achievements.isEmpty else { return }
        let gcAchievements = achievements.map { achievement -> GKAchievement in
            let a = GKAchievement(identifier: achievement.rawValue)
            a.percentComplete = 100
            a.showsCompletionBanner = true
            return a
        }
        do {
            try await GKAchievement.report(gcAchievements)
        } catch {
            print("Failed to report achievements: \(error.localizedDescription)")
        }
    }

    func loadHighScore() async -> Int? {
        guard isAuthenticated else { return nil }

        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return nil }

            let (localEntry, _) = try await leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime)

            return localEntry?.score
        } catch {
            print("Failed to load high score: \(error.localizedDescription)")
            return nil
        }
    }
}

class GameCenterDismissHandler: NSObject, GKGameCenterControllerDelegate {

    static let shared = GameCenterDismissHandler()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
