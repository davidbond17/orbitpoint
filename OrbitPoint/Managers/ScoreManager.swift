import Foundation

class ScoreManager {

    static let shared = ScoreManager()

    private let highScoreKey = "orbitpoint.highscore"
    private let currencyKey = "orbitpoint.currency"
    private let totalGamesKey = "orbitpoint.totalgames"
    private let totalTimeSurvivedKey = "orbitpoint.totaltime"
    private let totalCoinsEarnedKey = "orbitpoint.totalcoinsearned"
    private let totalCoinsSpentKey = "orbitpoint.totalcoinsspent"
    private let purchaseCountKey = "orbitpoint.purchasecount"

    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0
    private(set) var totalCurrency: Int = 0
    private(set) var lastEarnedCurrency: Int = 0

    private(set) var totalGamesPlayed: Int = 0
    private(set) var totalTimeSurvived: Int = 0
    private(set) var totalCoinsEarned: Int = 0
    private(set) var totalCoinsSpent: Int = 0
    private(set) var purchaseCount: Int = 0

    private var gameStartTime: TimeInterval = 0
    private var isRunning = false

    private init() {
        loadHighScore()
        loadCurrency()
        loadStats()
    }

    func startGame(at time: TimeInterval) {
        currentScore = 0
        lastEarnedCurrency = 0
        gameStartTime = time
        isRunning = true
    }

    func update(currentTime: TimeInterval) {
        guard isRunning else { return }
        currentScore = Int(currentTime - gameStartTime)
    }

    func adjustForPause(duration: TimeInterval) {
        gameStartTime += duration
    }

    func endGame() -> Bool {
        isRunning = false

        lastEarnedCurrency = currentScore
        totalCurrency += lastEarnedCurrency
        saveCurrency()

        totalGamesPlayed += 1
        totalTimeSurvived += currentScore
        totalCoinsEarned += currentScore
        saveStats()

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

    private func loadStats() {
        totalGamesPlayed = UserDefaults.standard.integer(forKey: totalGamesKey)
        totalTimeSurvived = UserDefaults.standard.integer(forKey: totalTimeSurvivedKey)
        totalCoinsEarned = UserDefaults.standard.integer(forKey: totalCoinsEarnedKey)
        totalCoinsSpent = UserDefaults.standard.integer(forKey: totalCoinsSpentKey)
        purchaseCount = UserDefaults.standard.integer(forKey: purchaseCountKey)
    }

    private func saveStats() {
        UserDefaults.standard.set(totalGamesPlayed, forKey: totalGamesKey)
        UserDefaults.standard.set(totalTimeSurvived, forKey: totalTimeSurvivedKey)
        UserDefaults.standard.set(totalCoinsEarned, forKey: totalCoinsEarnedKey)
        UserDefaults.standard.set(totalCoinsSpent, forKey: totalCoinsSpentKey)
        UserDefaults.standard.set(purchaseCount, forKey: purchaseCountKey)
    }

    func spendCurrency(_ amount: Int) -> Bool {
        guard totalCurrency >= amount else { return false }
        totalCurrency -= amount
        totalCoinsSpent += amount
        purchaseCount += 1
        saveCurrency()
        saveStats()
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
