import Foundation

class DailyBonusManager: ObservableObject {

    static let shared = DailyBonusManager()

    private let lastClaimDateKey = "orbitpoint.dailybonus.lastclaim"
    private let streakKey = "orbitpoint.dailybonus.streak"

    @Published private(set) var streak: Int = 0
    @Published private(set) var bonusAvailable: Bool = false

    private init() {
        load()
        checkAvailability()
    }

    var currentBonusAmount: Int {
        switch streak {
        case 0: return 15
        case 1: return 25
        case 2: return 40
        case 3: return 60
        case 4: return 80
        case 5: return 100
        default: return 150
        }
    }

    func checkAvailability() {
        guard let lastClaim = UserDefaults.standard.object(forKey: lastClaimDateKey) as? Date else {
            bonusAvailable = true
            return
        }
        let daysSinceClaim = Calendar.current.dateComponents([.day], from: lastClaim, to: Date()).day ?? 0
        if daysSinceClaim >= 2 {
            streak = 0
            save()
        }
        bonusAvailable = daysSinceClaim >= 1
    }

    func claimBonus() -> Int {
        guard bonusAvailable else { return 0 }
        let amount = currentBonusAmount
        streak += 1
        UserDefaults.standard.set(Date(), forKey: lastClaimDateKey)
        save()
        bonusAvailable = false
        ScoreManager.shared.addCurrency(amount)
        return amount
    }

    private func load() {
        streak = UserDefaults.standard.integer(forKey: streakKey)
    }

    private func save() {
        UserDefaults.standard.set(streak, forKey: streakKey)
    }
}
