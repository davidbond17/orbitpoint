import Foundation

class ScoreManager {

    static let shared = ScoreManager()

    private let highScoreKey = "orbitpoint.highscore"

    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0

    private var gameStartTime: TimeInterval = 0
    private var isRunning = false

    private init() {
        loadHighScore()
    }

    func startGame(at time: TimeInterval) {
        currentScore = 0
        gameStartTime = time
        isRunning = true
    }

    func update(currentTime: TimeInterval) {
        guard isRunning else { return }
        currentScore = Int(currentTime - gameStartTime)
    }

    func endGame() -> Bool {
        isRunning = false
        if currentScore > highScore {
            highScore = currentScore
            saveHighScore()
            return true
        }
        return false
    }

    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: highScoreKey)
    }

    func resetHighScore() {
        highScore = 0
        UserDefaults.standard.removeObject(forKey: highScoreKey)
    }
}
