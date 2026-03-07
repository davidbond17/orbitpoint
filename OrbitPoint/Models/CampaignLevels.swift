import Foundation

enum CampaignLevels {

    static func levels(for zone: Int) -> [LevelConfig] {
        switch zone {
        case 1: return zone1
        case 2: return zone2
        case 3: return zone3
        case 4: return zone4
        case 5: return zone5
        default: return []
        }
    }

    static let allZones: [Int] = [1, 2, 3, 4, 5]

    static func level(zone: Int, level: Int) -> LevelConfig? {
        levels(for: zone).first { $0.level == level }
    }

    // MARK: - Zone 1: Sol's Edge (Tutorial + Baseline)
    // Gentle introduction — standard debris, increasing target times

    static let zone1: [LevelConfig] = [
        LevelConfig(
            id: "1-1", zone: 1, level: 1,
            name: "First Contact",
            targetTime: 15, twoStarTime: 23, threeStarTime: 30,
            bonusObjective: nil,
            coinRewards: (10, 20, 35),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 2.5,
                minimumSpawnInterval: 1.5,
                difficultyRampDuration: 60,
                debrisSpeedRange: 70...120,
                safeZoneRadius: 170
            )
        ),
        LevelConfig(
            id: "1-2", zone: 1, level: 2,
            name: "Orbit Training",
            targetTime: 20, twoStarTime: 30, threeStarTime: 40,
            bonusObjective: .reverseCount(10),
            coinRewards: (10, 25, 40),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 2.2,
                minimumSpawnInterval: 1.2,
                difficultyRampDuration: 60,
                debrisSpeedRange: 75...130,
                safeZoneRadius: 165
            )
        ),
        LevelConfig(
            id: "1-3", zone: 1, level: 3,
            name: "Debris Field",
            targetTime: 25, twoStarTime: 38, threeStarTime: 50,
            bonusObjective: nil,
            coinRewards: (12, 28, 45),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 2.0,
                minimumSpawnInterval: 1.0,
                difficultyRampDuration: 70,
                debrisSpeedRange: 80...140,
                safeZoneRadius: 160
            )
        ),
        LevelConfig(
            id: "1-4", zone: 1, level: 4,
            name: "Steady Hand",
            targetTime: 25, twoStarTime: 38, threeStarTime: 50,
            bonusObjective: .noReverseFor(8),
            coinRewards: (12, 28, 45),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 2.0,
                minimumSpawnInterval: 0.9,
                difficultyRampDuration: 70,
                debrisSpeedRange: 80...140,
                safeZoneRadius: 155
            )
        ),
        LevelConfig(
            id: "1-5", zone: 1, level: 5,
            name: "Picking Up Speed",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: nil,
            coinRewards: (15, 30, 50),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.8,
                minimumSpawnInterval: 0.8,
                difficultyRampDuration: 80,
                debrisSpeedRange: 85...150,
                safeZoneRadius: 155
            )
        ),
        LevelConfig(
            id: "1-6", zone: 1, level: 6,
            name: "Close Quarters",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: .reverseCount(20),
            coinRewards: (15, 32, 50),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.8,
                minimumSpawnInterval: 0.7,
                difficultyRampDuration: 80,
                debrisSpeedRange: 85...150,
                safeZoneRadius: 150
            )
        ),
        LevelConfig(
            id: "1-7", zone: 1, level: 7,
            name: "No Margin",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: nil,
            coinRewards: (18, 35, 55),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.7,
                minimumSpawnInterval: 0.6,
                difficultyRampDuration: 90,
                debrisSpeedRange: 90...155,
                safeZoneRadius: 150
            )
        ),
        LevelConfig(
            id: "1-8", zone: 1, level: 8,
            name: "Patience",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: .noReverseFor(10),
            coinRewards: (18, 35, 55),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.6,
                minimumSpawnInterval: 0.55,
                difficultyRampDuration: 90,
                debrisSpeedRange: 90...155,
                safeZoneRadius: 150
            )
        ),
        LevelConfig(
            id: "1-9", zone: 1, level: 9,
            name: "The Gauntlet",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: nil,
            coinRewards: (20, 40, 60),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.5,
                minimumSpawnInterval: 0.5,
                difficultyRampDuration: 100,
                debrisSpeedRange: 90...160,
                safeZoneRadius: 150
            )
        ),
        LevelConfig(
            id: "1-10", zone: 1, level: 10,
            name: "Sol's Trial",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: .reverseCount(30),
            coinRewards: (25, 45, 70),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.4,
                minimumSpawnInterval: 0.45,
                difficultyRampDuration: 110,
                debrisSpeedRange: 90...160,
                safeZoneRadius: 150
            )
        ),
    ]

    // MARK: - Zone 2: Crimson Nebula (Faster debris, tighter windows)

    static let zone2: [LevelConfig] = [
        LevelConfig(
            id: "2-1", zone: 2, level: 1,
            name: "Red Shift",
            targetTime: 25, twoStarTime: 38, threeStarTime: 50,
            bonusObjective: nil,
            coinRewards: (15, 30, 50),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.8,
                minimumSpawnInterval: 0.7,
                difficultyRampDuration: 70,
                debrisSpeedRange: 90...160,
                safeZoneRadius: 145
            )
        ),
        LevelConfig(
            id: "2-2", zone: 2, level: 2,
            name: "Ember Storm",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: .reverseCount(15),
            coinRewards: (18, 35, 55),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.6,
                minimumSpawnInterval: 0.6,
                difficultyRampDuration: 75,
                debrisSpeedRange: 95...170,
                safeZoneRadius: 140
            )
        ),
        LevelConfig(
            id: "2-3", zone: 2, level: 3,
            name: "Scatterfield",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: nil,
            coinRewards: (18, 35, 55),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.5,
                minimumSpawnInterval: 0.55,
                difficultyRampDuration: 75,
                debrisSpeedRange: 95...170,
                safeZoneRadius: 140
            )
        ),
        LevelConfig(
            id: "2-4", zone: 2, level: 4,
            name: "Heat Wave",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: .noReverseFor(10),
            coinRewards: (20, 40, 60),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.4,
                minimumSpawnInterval: 0.5,
                difficultyRampDuration: 80,
                debrisSpeedRange: 100...175,
                safeZoneRadius: 135
            )
        ),
        LevelConfig(
            id: "2-5", zone: 2, level: 5,
            name: "Firestorm",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: nil,
            coinRewards: (20, 40, 60),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.3,
                minimumSpawnInterval: 0.45,
                difficultyRampDuration: 80,
                debrisSpeedRange: 100...175,
                safeZoneRadius: 135
            )
        ),
        LevelConfig(
            id: "2-6", zone: 2, level: 6,
            name: "Solar Wind",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: .reverseCount(25),
            coinRewards: (22, 42, 65),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.2,
                minimumSpawnInterval: 0.42,
                difficultyRampDuration: 85,
                debrisSpeedRange: 105...180,
                safeZoneRadius: 130
            )
        ),
        LevelConfig(
            id: "2-7", zone: 2, level: 7,
            name: "Magma Current",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: nil,
            coinRewards: (22, 42, 65),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.1,
                minimumSpawnInterval: 0.4,
                difficultyRampDuration: 90,
                debrisSpeedRange: 105...180,
                safeZoneRadius: 130
            )
        ),
        LevelConfig(
            id: "2-8", zone: 2, level: 8,
            name: "Crimson Trial",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: .noReverseFor(12),
            coinRewards: (25, 48, 75),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.0,
                minimumSpawnInterval: 0.38,
                difficultyRampDuration: 95,
                debrisSpeedRange: 110...185,
                safeZoneRadius: 130
            )
        ),
    ]

    // MARK: - Zone 3: Frozen Expanse (Slower debris, faster orbit implied)

    static let zone3: [LevelConfig] = [
        LevelConfig(
            id: "3-1", zone: 3, level: 1,
            name: "Cold Front",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: nil,
            coinRewards: (18, 35, 55),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 2.0,
                minimumSpawnInterval: 0.6,
                difficultyRampDuration: 70,
                debrisSpeedRange: 60...120,
                safeZoneRadius: 140
            )
        ),
        LevelConfig(
            id: "3-2", zone: 3, level: 2,
            name: "Ice Drift",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: .noReverseFor(12),
            coinRewards: (20, 40, 60),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.8,
                minimumSpawnInterval: 0.55,
                difficultyRampDuration: 75,
                debrisSpeedRange: 65...125,
                safeZoneRadius: 135
            )
        ),
        LevelConfig(
            id: "3-3", zone: 3, level: 3,
            name: "Crystal Rain",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: nil,
            coinRewards: (20, 40, 60),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.6,
                minimumSpawnInterval: 0.5,
                difficultyRampDuration: 75,
                debrisSpeedRange: 65...130,
                safeZoneRadius: 135
            )
        ),
        LevelConfig(
            id: "3-4", zone: 3, level: 4,
            name: "Permafrost",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: .reverseCount(20),
            coinRewards: (22, 42, 65),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.5,
                minimumSpawnInterval: 0.45,
                difficultyRampDuration: 80,
                debrisSpeedRange: 70...135,
                safeZoneRadius: 130
            )
        ),
        LevelConfig(
            id: "3-5", zone: 3, level: 5,
            name: "Glacial Surge",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: nil,
            coinRewards: (22, 42, 65),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.3,
                minimumSpawnInterval: 0.42,
                difficultyRampDuration: 80,
                debrisSpeedRange: 70...140,
                safeZoneRadius: 130
            )
        ),
        LevelConfig(
            id: "3-6", zone: 3, level: 6,
            name: "Shatter Point",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: .noReverseFor(14),
            coinRewards: (25, 48, 75),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.2,
                minimumSpawnInterval: 0.4,
                difficultyRampDuration: 85,
                debrisSpeedRange: 75...145,
                safeZoneRadius: 125
            )
        ),
        LevelConfig(
            id: "3-7", zone: 3, level: 7,
            name: "Absolute Zero",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: nil,
            coinRewards: (25, 48, 75),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.1,
                minimumSpawnInterval: 0.38,
                difficultyRampDuration: 90,
                debrisSpeedRange: 75...150,
                safeZoneRadius: 125
            )
        ),
        LevelConfig(
            id: "3-8", zone: 3, level: 8,
            name: "Frozen Trial",
            targetTime: 50, twoStarTime: 75, threeStarTime: 100,
            bonusObjective: .reverseCount(30),
            coinRewards: (28, 52, 80),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.0,
                minimumSpawnInterval: 0.35,
                difficultyRampDuration: 95,
                debrisSpeedRange: 80...155,
                safeZoneRadius: 120
            )
        ),
    ]

    // MARK: - Zone 4: Void Rift (Unpredictable, fast ramp)

    static let zone4: [LevelConfig] = [
        LevelConfig(
            id: "4-1", zone: 4, level: 1,
            name: "Rift Entry",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: nil,
            coinRewards: (22, 42, 65),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.5,
                minimumSpawnInterval: 0.5,
                difficultyRampDuration: 60,
                debrisSpeedRange: 100...180,
                safeZoneRadius: 130
            )
        ),
        LevelConfig(
            id: "4-2", zone: 4, level: 2,
            name: "Gravity Flux",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: .reverseCount(20),
            coinRewards: (25, 45, 70),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.4,
                minimumSpawnInterval: 0.45,
                difficultyRampDuration: 65,
                debrisSpeedRange: 105...185,
                safeZoneRadius: 125
            )
        ),
        LevelConfig(
            id: "4-3", zone: 4, level: 3,
            name: "Warp Zone",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: nil,
            coinRewards: (25, 45, 70),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.3,
                minimumSpawnInterval: 0.42,
                difficultyRampDuration: 65,
                debrisSpeedRange: 105...190,
                safeZoneRadius: 125
            )
        ),
        LevelConfig(
            id: "4-4", zone: 4, level: 4,
            name: "Singularity",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: .noReverseFor(12),
            coinRewards: (28, 50, 75),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.2,
                minimumSpawnInterval: 0.4,
                difficultyRampDuration: 70,
                debrisSpeedRange: 110...195,
                safeZoneRadius: 120
            )
        ),
        LevelConfig(
            id: "4-5", zone: 4, level: 5,
            name: "Event Horizon",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: nil,
            coinRewards: (28, 50, 75),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.1,
                minimumSpawnInterval: 0.38,
                difficultyRampDuration: 70,
                debrisSpeedRange: 110...200,
                safeZoneRadius: 120
            )
        ),
        LevelConfig(
            id: "4-6", zone: 4, level: 6,
            name: "Dark Matter",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: .reverseCount(30),
            coinRewards: (30, 55, 80),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.0,
                minimumSpawnInterval: 0.35,
                difficultyRampDuration: 75,
                debrisSpeedRange: 115...200,
                safeZoneRadius: 115
            )
        ),
        LevelConfig(
            id: "4-7", zone: 4, level: 7,
            name: "Collapse",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: nil,
            coinRewards: (30, 55, 80),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.9,
                minimumSpawnInterval: 0.33,
                difficultyRampDuration: 80,
                debrisSpeedRange: 115...200,
                safeZoneRadius: 115
            )
        ),
        LevelConfig(
            id: "4-8", zone: 4, level: 8,
            name: "Void Trial",
            targetTime: 50, twoStarTime: 75, threeStarTime: 100,
            bonusObjective: .noReverseFor(15),
            coinRewards: (35, 60, 90),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.8,
                minimumSpawnInterval: 0.3,
                difficultyRampDuration: 85,
                debrisSpeedRange: 120...210,
                safeZoneRadius: 110
            )
        ),
    ]

    // MARK: - Zone 5: Supernova Core (Maximum difficulty)

    static let zone5: [LevelConfig] = [
        LevelConfig(
            id: "5-1", zone: 5, level: 1,
            name: "Core Breach",
            targetTime: 30, twoStarTime: 45, threeStarTime: 60,
            bonusObjective: nil,
            coinRewards: (30, 55, 80),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.2,
                minimumSpawnInterval: 0.4,
                difficultyRampDuration: 50,
                debrisSpeedRange: 110...200,
                safeZoneRadius: 120
            )
        ),
        LevelConfig(
            id: "5-2", zone: 5, level: 2,
            name: "Plasma Tide",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: .reverseCount(25),
            coinRewards: (32, 58, 85),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.1,
                minimumSpawnInterval: 0.38,
                difficultyRampDuration: 55,
                debrisSpeedRange: 115...205,
                safeZoneRadius: 115
            )
        ),
        LevelConfig(
            id: "5-3", zone: 5, level: 3,
            name: "Meltdown",
            targetTime: 35, twoStarTime: 52, threeStarTime: 70,
            bonusObjective: nil,
            coinRewards: (32, 58, 85),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 1.0,
                minimumSpawnInterval: 0.35,
                difficultyRampDuration: 55,
                debrisSpeedRange: 120...210,
                safeZoneRadius: 115
            )
        ),
        LevelConfig(
            id: "5-4", zone: 5, level: 4,
            name: "Chain Reaction",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: .noReverseFor(14),
            coinRewards: (35, 62, 90),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.9,
                minimumSpawnInterval: 0.32,
                difficultyRampDuration: 60,
                debrisSpeedRange: 120...215,
                safeZoneRadius: 110
            )
        ),
        LevelConfig(
            id: "5-5", zone: 5, level: 5,
            name: "Critical Mass",
            targetTime: 40, twoStarTime: 60, threeStarTime: 80,
            bonusObjective: nil,
            coinRewards: (35, 62, 90),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.85,
                minimumSpawnInterval: 0.3,
                difficultyRampDuration: 60,
                debrisSpeedRange: 125...220,
                safeZoneRadius: 110
            )
        ),
        LevelConfig(
            id: "5-6", zone: 5, level: 6,
            name: "Detonation",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: .reverseCount(35),
            coinRewards: (38, 65, 95),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.8,
                minimumSpawnInterval: 0.28,
                difficultyRampDuration: 65,
                debrisSpeedRange: 125...225,
                safeZoneRadius: 105
            )
        ),
        LevelConfig(
            id: "5-7", zone: 5, level: 7,
            name: "Stellar Death",
            targetTime: 45, twoStarTime: 68, threeStarTime: 90,
            bonusObjective: nil,
            coinRewards: (38, 65, 95),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.75,
                minimumSpawnInterval: 0.26,
                difficultyRampDuration: 70,
                debrisSpeedRange: 130...230,
                safeZoneRadius: 105
            )
        ),
        LevelConfig(
            id: "5-8", zone: 5, level: 8,
            name: "Last Light",
            targetTime: 50, twoStarTime: 75, threeStarTime: 100,
            bonusObjective: .noReverseFor(16),
            coinRewards: (40, 70, 100),
            debrisConfig: DebrisConfig(
                initialSpawnInterval: 0.7,
                minimumSpawnInterval: 0.25,
                difficultyRampDuration: 75,
                debrisSpeedRange: 130...240,
                safeZoneRadius: 100
            )
        ),
    ]
}
