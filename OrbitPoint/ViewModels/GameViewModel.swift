import SwiftUI
import SpriteKit

enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

@MainActor
class GameViewModel: ObservableObject {

    @Published var gameState: GameState = .menu
    @Published var lastScore: Int = 0
    @Published var isNewHighScore: Bool = false
    @Published var showSettings: Bool = false
    @Published var showLeaderboard: Bool = false
    @Published var showStore: Bool = false
    @Published var showHowToPlay: Bool = false
    @Published var showDailyBonus: Bool = false
    @Published var newMilestoneUnlock: StoreItem? = nil

    private let hasSeenTutorialKey = "orbitpoint.hasSeenTutorial"

    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true

    var highScore: Int {
        ScoreManager.shared.highScore
    }

    var totalCurrency: Int {
        ScoreManager.shared.totalCurrency
    }

    var lastEarnedCurrency: Int {
        ScoreManager.shared.lastEarnedCurrency
    }

    var isGameCenterAuthenticated: Bool {
        GameCenterManager.shared.isAuthenticated
    }

    private var gameScene: GameScene?

    func setGameScene(_ scene: GameScene) {
        self.gameScene = scene
    }

    func startGame() {
        gameState = .playing
        GameCenterManager.shared.showAccessPoint(false)
        gameScene?.startGame()
    }

    func handleGameOver(score: Int, isNewHighScore: Bool) {
        self.lastScore = score
        self.isNewHighScore = isNewHighScore
        gameState = .gameOver

        checkMilestoneUnlocks(score: score)

        Task {
            await GameCenterManager.shared.submitScore(score)
            await GameCenterManager.shared.reportAchievementsAfterGame(score: score)
        }
    }

    private func checkMilestoneUnlocks(score: Int) {
        let stats = ScoreManager.shared
        let store = StoreManager.shared
        let milestoneItems: [(StoreItem, Bool)] = [
            (StoreItems.satellites.first(where: { $0.id == "satellite_aurora" })!, score >= 60),
            (StoreItems.suns.first(where: { $0.id == "sun_pulsar" })!, stats.totalGamesPlayed >= 10),
            (StoreItems.debris.first(where: { $0.id == "debris_galaxy" })!, score >= 120)
        ]
        for (item, earned) in milestoneItems where earned && !store.isUnlocked(item.id) {
            store.unlockMilestoneItem(item)
            newMilestoneUnlock = item
            break
        }
    }

    func returnToMenu() {
        gameState = .menu
        gameScene?.setScoreVisible(false)
        gameScene?.stopGame()
        GameCenterManager.shared.showAccessPoint(true)
    }

    func pauseGame() {
        gameState = .paused
        gameScene?.pauseScene()
    }

    func resumeGame() {
        gameState = .playing
        gameScene?.resumeScene()
    }

    func showGameCenterLeaderboard() {
        GameCenterManager.shared.showLeaderboard()
    }

    func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: hasSeenTutorialKey) {
            showHowToPlay = true
        }
        DailyBonusManager.shared.checkAvailability()
        if DailyBonusManager.shared.bonusAvailable {
            showDailyBonus = true
        }
    }

    func markTutorialSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenTutorialKey)
    }
}
