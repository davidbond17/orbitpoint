import Foundation

class ScoreManager {

    static let shared = ScoreManager()

    private let highScoreKey = "orbitpoint.highscore"
    private let currencyKey = "orbitpoint.currency"

    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0
    private(set) var totalCurrency: Int = 0
    private(set) var lastEarnedCurrency: Int = 0

    private var gameStartTime: TimeInterval = 0
    private var totalPausedDuration: TimeInterval = 0
    private var pauseStartTime: TimeInterval = 0
    private var isRunning = false

    private init() {
        loadHighScore()
        loadCurrency()
    }

    func startGame(at time: TimeInterval) {
        currentScore = 0
        lastEarnedCurrency = 0
        gameStartTime = time
        totalPausedDuration = 0
        pauseStartTime = 0
        isRunning = true
    }

    func pause(at time: TimeInterval) {
        guard isRunning else { return }
        pauseStartTime = time
    }

    func resume(at time: TimeInterval) {
        guard isRunning, pauseStartTime > 0 else { return }
        totalPausedDuration += time - pauseStartTime
        pauseStartTime = 0
    }

    func update(currentTime: TimeInterval) {
        guard isRunning else { return }
        currentScore = Int(currentTime - gameStartTime - totalPausedDuration)
    }

    func endGame() -> Bool {
        isRunning = false

        lastEarnedCurrency = currentScore
        totalCurrency += lastEarnedCurrency
        saveCurrency()

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

    private func loadCurrency() {
        totalCurrency = UserDefaults.standard.integer(forKey: currencyKey)
    }

    private func saveCurrency() {
        UserDefaults.standard.set(totalCurrency, forKey: currencyKey)
    }

    func spendCurrency(_ amount: Int) -> Bool {
        guard totalCurrency >= amount else { return false }
        totalCurrency -= amount
        saveCurrency()
        return true
    }

    func addCurrency(_ amount: Int) {
        totalCurrency += amount
        saveCurrency()
    }

    func resetHighScore() {
        highScore = 0
        UserDefaults.standard.removeObject(forKey: highScoreKey)
    }

    func resetCurrency() {
        totalCurrency = 0
        UserDefaults.standard.removeObject(forKey: currencyKey)
    }
}
