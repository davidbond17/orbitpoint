import GameKit
import SwiftUI

@MainActor
class GameCenterManager: ObservableObject {

    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?

    private let leaderboardID = "com.davidbond.orbitpoint.leaderboard.main"

    private init() {}

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let error = error {
                    print("Game Center authentication failed: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    return
                }

                if viewController != nil {
                    self?.isAuthenticated = false
                    return
                }

                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    self?.localPlayer = GKLocalPlayer.local
                    self?.configureAccessPoint()
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
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
