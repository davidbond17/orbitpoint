import SwiftUI
import SpriteKit

enum GameState {
    case menu
    case playing
    case paused
    case gameOver
    case campaignMap
    case campaignLevelComplete
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

    @Published var currentGameMode: GameMode = .freePlay
    @Published var lastLevelResult: LevelResult?
    @Published var selectedZone: Int = 1

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

    func startFreePlay() {
        currentGameMode = .freePlay
        gameScene?.configureForMode(.freePlay)
        gameState = .playing
        GameCenterManager.shared.showAccessPoint(false)
        gameScene?.startGame()
    }

    func startCampaignLevel(zone: Int, level: Int) {
        currentGameMode = .campaign(zone: zone, level: level)
        gameScene?.configureForMode(.campaign(zone: zone, level: level))
        gameState = .playing
        GameCenterManager.shared.showAccessPoint(false)
        gameScene?.startGame()
    }

    func startGame() {
        switch currentGameMode {
        case .freePlay:
            startFreePlay()
        case .campaign(let zone, let level):
            startCampaignLevel(zone: zone, level: level)
        }
    }

    func handleGameOver(score: Int, isNewHighScore: Bool) {
        self.lastScore = score
        self.isNewHighScore = isNewHighScore
        gameState = .gameOver

        Task {
            await GameCenterManager.shared.submitScore(score)
        }
    }

    func handleCampaignLevelEnd(result: LevelResult) {
        self.lastLevelResult = result
        self.lastScore = Int(result.survivalTime)
        gameState = .campaignLevelComplete
    }

    func returnToMenu() {
        currentGameMode = .freePlay
        gameState = .menu
        gameScene?.setScoreVisible(false)
        gameScene?.stopGame()
        GameCenterManager.shared.showAccessPoint(true)
    }

    func returnToCampaignMap() {
        gameState = .campaignMap
        gameScene?.setScoreVisible(false)
        gameScene?.stopGame()
    }

    func showCampaignMap() {
        gameState = .campaignMap
        GameCenterManager.shared.showAccessPoint(false)
    }

    func pauseGame() {
        gameState = .paused
        gameScene?.isPaused = true
    }

    func resumeGame() {
        gameState = .playing
        gameScene?.isPaused = false
    }

    func showGameCenterLeaderboard() {
        GameCenterManager.shared.showLeaderboard()
    }

    func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: hasSeenTutorialKey) {
            showHowToPlay = true
        }
    }

    func markTutorialSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenTutorialKey)
    }
}
