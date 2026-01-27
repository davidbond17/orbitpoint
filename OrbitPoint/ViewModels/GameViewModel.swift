import SwiftUI
import SpriteKit

enum GameState {
    case menu
    case playing
    case gameOver
}

@MainActor
class GameViewModel: ObservableObject {

    @Published var gameState: GameState = .menu
    @Published var lastScore: Int = 0
    @Published var isNewHighScore: Bool = false
    @Published var showSettings: Bool = false
    @Published var showLeaderboard: Bool = false

    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true

    var highScore: Int {
        ScoreManager.shared.highScore
    }

    private var gameScene: GameScene?

    func setGameScene(_ scene: GameScene) {
        self.gameScene = scene
    }

    func startGame() {
        gameState = .playing
        gameScene?.startGame()
    }

    func handleGameOver(score: Int, isNewHighScore: Bool) {
        self.lastScore = score
        self.isNewHighScore = isNewHighScore
        gameState = .gameOver
    }

    func returnToMenu() {
        gameState = .menu
    }
}
