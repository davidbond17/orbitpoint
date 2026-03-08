import Foundation

class DailyChallengeManager {

    static let shared = DailyChallengeManager()

    private let bestTimeKey = "orbitpoint.daily.besttime"
    private let completionDateKey = "orbitpoint.daily.completiondate"
    private let streakKey = "orbitpoint.daily.streak"

    private(set) var currentStreak: Int = 0

    var todaysSeed: Int {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        let day = cal.component(.day, from: now)
        return year * 10000 + month * 100 + day
    }

    var hasCompletedToday: Bool {
        guard let last = lastCompletionDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var todaysBestTime: Int {
        let key = "\(bestTimeKey).\(todaysSeed)"
        return UserDefaults.standard.integer(forKey: key)
    }

    private var lastCompletionDate: Date? {
        UserDefaults.standard.object(forKey: completionDateKey) as? Date
    }

    private init() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        checkStreakReset()
    }

    func generateConfig() -> (debrisConfig: DebrisConfig, targetTime: TimeInterval) {
        srand48(todaysSeed)

        let spawnInterval = 1.2 + drand48() * 0.8
        let minSpawn = 0.3 + drand48() * 0.3
        let speedLow = CGFloat(80 + drand48() * 40)
        let speedHigh = speedLow + CGFloat(60 + drand48() * 40)
        let targetTime = TimeInterval(30 + Int(drand48() * 20))

        let cometsEnabled = drand48() > 0.4
        let solarEnabled = drand48() > 0.5
        let gravityEnabled = drand48() > 0.7

        var hazards = HazardConfig()
        hazards.cometsEnabled = cometsEnabled
        hazards.cometInterval = 6.0 + drand48() * 4.0
        hazards.solarFlaresEnabled = solarEnabled
        hazards.solarFlareInterval = 8.0 + drand48() * 4.0
        hazards.gravityWellsEnabled = gravityEnabled
        hazards.gravityWellInterval = 10.0 + drand48() * 4.0

        let allTypes: [PowerUpType] = [.shield, .slowField, .phaseShift, .orbitBoost]
        let typeCount = 2 + Int(drand48() * 2)
        let availableTypes = Array(allTypes.shuffled().prefix(typeCount))
        let powerUps = PowerUpConfig(enabled: true, spawnInterval: 12.0 + drand48() * 6.0, availableTypes: availableTypes)

        let multiOrbit = drand48() > 0.3

        var config = DebrisConfig(
            initialSpawnInterval: spawnInterval,
            minimumSpawnInterval: minSpawn,
            difficultyRampDuration: 60.0,
            debrisSpeedRange: speedLow...speedHigh,
            safeZoneRadius: 150
        )
        config.hazards = hazards
        config.powerUps = powerUps
        config.multiOrbitEnabled = multiOrbit

        return (config, targetTime)
    }

    func completeChallenge(survivalTime: Int) -> Int {
        let key = "\(bestTimeKey).\(todaysSeed)"
        let currentBest = UserDefaults.standard.integer(forKey: key)
        if survivalTime > currentBest {
            UserDefaults.standard.set(survivalTime, forKey: key)
        }

        if !hasCompletedToday {
            if let last = lastCompletionDate, Calendar.current.isDateInYesterday(last) {
                currentStreak += 1
            } else if lastCompletionDate == nil || !Calendar.current.isDateInToday(lastCompletionDate!) {
                currentStreak = 1
            }
            UserDefaults.standard.set(Date(), forKey: completionDateKey)
            UserDefaults.standard.set(currentStreak, forKey: streakKey)
        }

        let bonus = min(50, 20 + 5 * currentStreak)
        return bonus
    }

    func checkStreakReset() {
        guard let last = lastCompletionDate else { return }
        let cal = Calendar.current
        if !cal.isDateInToday(last) && !cal.isDateInYesterday(last) {
            currentStreak = 0
            UserDefaults.standard.set(0, forKey: streakKey)
        }
    }
}
