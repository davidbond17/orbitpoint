import Foundation

enum GameMode: Equatable {
    case freePlay
    case campaign(zone: Int, level: Int)
    case zen
    case dailyChallenge
    case gauntlet
    case timeAttack
}

struct LevelConfig: Identifiable {
    let id: String
    let zone: Int
    let level: Int
    let name: String
    let targetTime: TimeInterval
    let twoStarTime: TimeInterval
    let threeStarTime: TimeInterval
    let bonusObjective: BonusObjective?
    let coinRewards: (oneStar: Int, twoStar: Int, threeStar: Int)
    var debrisConfig: DebrisConfig

    var displayName: String {
        "\(zone)-\(level)"
    }
}

struct DebrisConfig {
    let initialSpawnInterval: TimeInterval
    let minimumSpawnInterval: TimeInterval
    let difficultyRampDuration: TimeInterval
    let debrisSpeedRange: ClosedRange<CGFloat>
    let safeZoneRadius: CGFloat
    var hazards: HazardConfig = HazardConfig()
    var powerUps: PowerUpConfig = PowerUpConfig()
    var multiOrbitEnabled: Bool = false

    static let standard = DebrisConfig(
        initialSpawnInterval: 2.0,
        minimumSpawnInterval: 0.4,
        difficultyRampDuration: 120.0,
        debrisSpeedRange: 80...160,
        safeZoneRadius: 150
    )
}

struct HazardConfig {
    var cometsEnabled: Bool = false
    var cometInterval: TimeInterval = 8.0
    var cometSpeedMultiplier: CGFloat = 2.0

    var solarFlaresEnabled: Bool = false
    var solarFlareInterval: TimeInterval = 10.0

    var gravityWellsEnabled: Bool = false
    var gravityWellInterval: TimeInterval = 12.0
}

enum BonusObjective: Equatable {
    case reverseCount(Int)
    case noReverseFor(TimeInterval)

    var description: String {
        switch self {
        case .reverseCount(let count):
            return "Reverse direction \(count) times"
        case .noReverseFor(let seconds):
            return "Don't reverse for \(Int(seconds))s straight"
        }
    }
}

struct LevelResult {
    let levelConfig: LevelConfig
    let survivalTime: TimeInterval
    let earnedCoins: Int
    let starsEarned: Int
    let bonusCompleted: Bool
    let reverseCount: Int

    var passed: Bool {
        survivalTime >= levelConfig.targetTime
    }
}
