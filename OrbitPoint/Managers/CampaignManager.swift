import Foundation

class CampaignManager: ObservableObject {

    static let shared = CampaignManager()

    private let starsKey = "orbitpoint.campaign.stars"
    private let completedKey = "orbitpoint.campaign.completed"
    private let bestTimesKey = "orbitpoint.campaign.bestTimes"
    private let seenBriefingsKey = "orbitpoint.campaign.seenBriefings"

    private var seenBriefings: Set<Int> = []

    @Published private(set) var levelStars: [String: Int] = [:]
    @Published private(set) var completedLevels: Set<String> = []
    @Published private(set) var bestTimes: [String: TimeInterval] = [:]

    var totalStars: Int {
        levelStars.values.reduce(0, +)
    }

    private init() {
        loadProgress()
    }

    // MARK: - Mission Briefings

    func shouldShowBriefing(for zone: Int) -> Bool {
        !seenBriefings.contains(zone)
    }

    func markBriefingSeen(for zone: Int) {
        seenBriefings.insert(zone)
        UserDefaults.standard.set(Array(seenBriefings), forKey: seenBriefingsKey)
    }

    // MARK: - Zone/Level Access

    func isZoneUnlocked(_ zone: Int) -> Bool {
        let theme = ZoneThemes.theme(for: zone)
        return totalStars >= theme.requiredStars
    }

    func isLevelUnlocked(zone: Int, level: Int) -> Bool {
        guard isZoneUnlocked(zone) else { return false }
        if level == 1 { return true }
        let previousId = levelId(zone: zone, level: level - 1)
        return completedLevels.contains(previousId)
    }

    func starsForLevel(zone: Int, level: Int) -> Int {
        levelStars[levelId(zone: zone, level: level)] ?? 0
    }

    func starsForZone(_ zone: Int) -> Int {
        let levels = CampaignLevels.levels(for: zone)
        return levels.reduce(0) { $0 + starsForLevel(zone: zone, level: $1.level) }
    }

    func maxStarsForZone(_ zone: Int) -> Int {
        CampaignLevels.levels(for: zone).count * 3
    }

    func bestTimeForLevel(zone: Int, level: Int) -> TimeInterval? {
        bestTimes[levelId(zone: zone, level: level)]
    }

    // MARK: - Level Completion

    func completeLevel(_ result: LevelResult) {
        let id = levelId(zone: result.levelConfig.zone, level: result.levelConfig.level)

        guard result.passed else { return }

        completedLevels.insert(id)

        let stars = calculateStars(for: result)
        let existingStars = levelStars[id] ?? 0
        if stars > existingStars {
            levelStars[id] = stars
        }

        let existingBest = bestTimes[id] ?? 0
        if result.survivalTime > existingBest {
            bestTimes[id] = result.survivalTime
        }

        saveProgress()
    }

    func calculateStars(for result: LevelResult) -> Int {
        guard result.passed else { return 0 }

        let config = result.levelConfig
        if result.survivalTime >= config.threeStarTime {
            return 3
        } else if result.survivalTime >= config.twoStarTime {
            return 2
        } else {
            return 1
        }
    }

    func coinReward(for result: LevelResult) -> Int {
        let stars = calculateStars(for: result)
        let config = result.levelConfig
        switch stars {
        case 3: return config.coinRewards.threeStar
        case 2: return config.coinRewards.twoStar
        case 1: return config.coinRewards.oneStar
        default: return 0
        }
    }

    // MARK: - Progress

    func zoneProgress(_ zone: Int) -> Double {
        let levels = CampaignLevels.levels(for: zone)
        guard !levels.isEmpty else { return 0 }
        let completed = levels.filter { completedLevels.contains(levelId(zone: zone, level: $0.level)) }.count
        return Double(completed) / Double(levels.count)
    }

    // MARK: - Persistence

    private func loadProgress() {
        if let data = UserDefaults.standard.dictionary(forKey: starsKey) as? [String: Int] {
            levelStars = data
        }
        if let data = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedLevels = Set(data)
        }
        if let data = UserDefaults.standard.dictionary(forKey: bestTimesKey) as? [String: TimeInterval] {
            bestTimes = data
        }
        if let data = UserDefaults.standard.array(forKey: seenBriefingsKey) as? [Int] {
            seenBriefings = Set(data)
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(levelStars, forKey: starsKey)
        UserDefaults.standard.set(Array(completedLevels), forKey: completedKey)
        UserDefaults.standard.set(bestTimes, forKey: bestTimesKey)
    }

    // MARK: - Helpers

    private func levelId(zone: Int, level: Int) -> String {
        "\(zone)-\(level)"
    }
}
