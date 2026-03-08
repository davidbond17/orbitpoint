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
    @Published var showDailyBonus: Bool = false
    @Published var showLoreIntro: Bool = false
    @Published var showCodex: Bool = false
    @Published var newMilestoneUnlock: StoreItem? = nil
    @Published var collectedLoreFragment: LoreFragment? = nil
    @Published var activePowerUp: PowerUpType? = nil
    @Published var powerUpTimeRemaining: TimeInterval = 0
    @Published var powerUpToast: PowerUpType? = nil

    @Published var currentGameMode: GameMode = .freePlay
    @Published var lastLevelResult: LevelResult?
    @Published var selectedZone: Int = 1

    private let hasSeenTutorialKey = "orbitpoint.hasSeenTutorial"
    private let hasSeenLoreIntroKey = "orbitpoint.hasSeenLoreIntro"

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

    func startZenMode() {
        currentGameMode = .zen
        gameScene?.configureForMode(.zen)
        gameState = .playing
        GameCenterManager.shared.showAccessPoint(false)
        gameScene?.startGame()
    }

    func startDailyChallenge() {
        currentGameMode = .dailyChallenge
        gameScene?.configureForMode(.dailyChallenge)
        gameState = .playing
        GameCenterManager.shared.showAccessPoint(false)
        gameScene?.startGame()
    }

    func startGauntlet() {
        currentGameMode = .gauntlet
        gameScene?.configureForMode(.gauntlet)
        gameState = .playing
        GameCenterManager.shared.showAccessPoint(false)
        gameScene?.startGame()
    }

    func startTimeAttack() {
        currentGameMode = .timeAttack
        gameScene?.configureForMode(.timeAttack)
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
        case .zen:
            startZenMode()
        case .dailyChallenge:
            startDailyChallenge()
        case .gauntlet:
            startGauntlet()
        case .timeAttack:
            startTimeAttack()
        }
    }

    func handleGameOver(score: Int, isNewHighScore: Bool) {
        guard currentGameMode != .zen else { return }
        self.lastScore = score
        self.isNewHighScore = isNewHighScore
        gameState = .gameOver

        checkMilestoneUnlocks(score: score)

        Task {
            await GameCenterManager.shared.submitFreePlayScore(score)
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

    func handleCampaignLevelEnd(result: LevelResult) {
        self.lastLevelResult = result
        self.lastScore = Int(result.survivalTime)
        gameState = .campaignLevelComplete

        if result.passed {
            Task {
                await GameCenterManager.shared.submitCampaignLevelTime(
                    zone: result.levelConfig.zone,
                    level: result.levelConfig.level,
                    timeInSeconds: Int(result.survivalTime)
                )
                await GameCenterManager.shared.submitCampaignTotalStars(
                    CampaignManager.shared.totalStars
                )
                await GameCenterManager.shared.reportAchievementsAfterGame(score: Int(result.survivalTime))
            }
        }
    }

    func returnToMenu() {
        currentGameMode = .freePlay
        gameState = .menu
        activePowerUp = nil
        powerUpTimeRemaining = 0
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
        gameScene?.pauseScene()
    }

    func resumeGame() {
        gameScene?.resumeScene()
        gameState = .playing
    }

    func showGameCenterLeaderboard() {
        GameCenterManager.shared.showLeaderboard()
    }

    func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: hasSeenLoreIntroKey) {
            showLoreIntro = true
            return
        }
        if !UserDefaults.standard.bool(forKey: hasSeenTutorialKey) {
            showHowToPlay = true
        }
        DailyBonusManager.shared.checkAvailability()
        if DailyBonusManager.shared.bonusAvailable {
            showDailyBonus = true
        }
    }

    private var isReplayingIntro = false

    func replayLoreIntro() {
        isReplayingIntro = true
        showLoreIntro = true
    }

    func markLoreIntroSeen() {
        let wasReplay = isReplayingIntro
        isReplayingIntro = false
        UserDefaults.standard.set(true, forKey: hasSeenLoreIntroKey)
        showLoreIntro = false

        guard !wasReplay else { return }
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

    func handleLoreFragmentCollected(id: String) {
        LoreManager.shared.collectFragment(id)
        if let fragment = LoreFragments.fragment(for: id) {
            collectedLoreFragment = fragment
        }
    }

    func handlePowerUpCollected(type: PowerUpType) {
        withAnimation(.spring(response: 0.3)) {
            activePowerUp = type
            powerUpToast = type
        }
        if type != .shield {
            powerUpTimeRemaining = type.duration
        }
    }

    func handlePowerUpExpired() {
        withAnimation(.easeOut(duration: 0.3)) {
            activePowerUp = nil
            powerUpTimeRemaining = 0
        }
    }

    func handleShieldBroken() {
        withAnimation(.easeOut(duration: 0.3)) {
            activePowerUp = nil
        }
    }
}
