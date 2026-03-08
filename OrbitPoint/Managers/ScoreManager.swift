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
    private let gauntletBestRoundsKey = "orbitpoint.gauntlet.bestrounds"
    private let gauntletBestTimeKey = "orbitpoint.gauntlet.besttime"
    private let timeAttackBestTimeKey = "orbitpoint.timeattack.besttime"

    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0
    private(set) var totalCurrency: Int = 0
    private(set) var lastEarnedCurrency: Int = 0

    private(set) var totalGamesPlayed: Int = 0
    private(set) var totalTimeSurvived: Int = 0
    private(set) var totalCoinsEarned: Int = 0
    private(set) var totalCoinsSpent: Int = 0
    private(set) var purchaseCount: Int = 0
    private(set) var gauntletBestRounds: Int = 0
    private(set) var gauntletBestTime: Int = 0
    private(set) var timeAttackBestTime: Int = 0

    private var gameStartTime: TimeInterval = 0
    private var totalPausedDuration: TimeInterval = 0
    private var pauseStartTime: TimeInterval = 0
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
        gauntletBestRounds = UserDefaults.standard.integer(forKey: gauntletBestRoundsKey)
        gauntletBestTime = UserDefaults.standard.integer(forKey: gauntletBestTimeKey)
        timeAttackBestTime = UserDefaults.standard.integer(forKey: timeAttackBestTimeKey)
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

    func addBonusSeconds(_ seconds: Int) {
        currentScore += seconds
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

    func updateGauntletBest(rounds: Int, time: Int) -> Bool {
        var isNew = false
        if rounds > gauntletBestRounds {
            gauntletBestRounds = rounds
            UserDefaults.standard.set(rounds, forKey: gauntletBestRoundsKey)
            isNew = true
        }
        if time > gauntletBestTime {
            gauntletBestTime = time
            UserDefaults.standard.set(time, forKey: gauntletBestTimeKey)
        }
        return isNew
    }

    func updateTimeAttackBest(time: Int) -> Bool {
        if time > timeAttackBestTime {
            timeAttackBestTime = time
            UserDefaults.standard.set(time, forKey: timeAttackBestTimeKey)
            return true
        }
        return false
    }
}
