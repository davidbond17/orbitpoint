import Foundation

class PlayerProgressionManager: ObservableObject {

    static let shared = PlayerProgressionManager()

    private let totalXPKey = "orbitpoint.player.totalXP"
    private let currentLevelKey = "orbitpoint.player.level"

    @Published private(set) var totalXP: Int = 0
    @Published private(set) var currentLevel: Int = 1

    var xpProgressFraction: Double {
        let required = xpRequired(for: currentLevel)
        let previousRequired = currentLevel > 1 ? xpRequired(for: currentLevel - 1) : 0
        let levelXP = totalXP - previousRequired
        let needed = required - previousRequired
        guard needed > 0 else { return 0 }
        return min(Double(levelXP) / Double(needed), 1.0)
    }

    var levelTitle: String {
        switch currentLevel {
        case 1...5: return "Cadet"
        case 6...10: return "Pilot"
        case 11...15: return "Navigator"
        case 16...20: return "Commander"
        case 21...25: return "Captain"
        case 26...30: return "Admiral"
        default: return "Legend"
        }
    }

    var xpToNextLevel: Int {
        let required = xpRequired(for: currentLevel)
        return max(required - totalXP, 0)
    }

    private init() {
        totalXP = UserDefaults.standard.integer(forKey: totalXPKey)
        currentLevel = UserDefaults.standard.integer(forKey: currentLevelKey)
        if currentLevel < 1 { currentLevel = 1 }
    }

    func xpRequired(for level: Int) -> Int {
        guard level > 1 else { return 0 }
        return Int(50.0 * pow(Double(level - 1), 1.5))
    }

    @discardableResult
    func addXP(_ amount: Int) -> Bool {
        totalXP += amount
        UserDefaults.standard.set(totalXP, forKey: totalXPKey)

        var leveledUp = false
        while totalXP >= xpRequired(for: currentLevel) {
            currentLevel += 1
            leveledUp = true
        }
        UserDefaults.standard.set(currentLevel, forKey: currentLevelKey)

        objectWillChange.send()
        return leveledUp
    }

    func xpForGameResult(score: Int, mode: GameMode) -> Int {
        let baseXP = max(score / 10, 1)

        let multiplier: Double
        switch mode {
        case .campaign:
            multiplier = 2.0
        case .gauntlet:
            multiplier = 2.0
        case .zen:
            multiplier = 0.5
        case .dailyChallenge:
            return baseXP + 20
        case .freePlay:
            multiplier = 1.0
        case .timeAttack:
            multiplier = 1.5
        }

        return Int(Double(baseXP) * multiplier)
    }
}
