import Foundation

enum PowerUpType: String, CaseIterable {
    case shield
    case slowField
    case magnet
    case phaseShift
    case orbitBoost

    var duration: TimeInterval {
        switch self {
        case .shield: return .infinity
        case .slowField: return 6.0
        case .magnet: return 8.0
        case .phaseShift: return 3.0
        case .orbitBoost: return 10.0
        }
    }

    var displayName: String {
        switch self {
        case .shield: return "Shield"
        case .slowField: return "Slow Field"
        case .magnet: return "Magnet"
        case .phaseShift: return "Phase Shift"
        case .orbitBoost: return "Orbit Boost"
        }
    }

    var iconName: String {
        switch self {
        case .shield: return "shield.fill"
        case .slowField: return "clock.arrow.circlepath"
        case .magnet: return "lines.measurement.horizontal"
        case .phaseShift: return "wave.3.right"
        case .orbitBoost: return "bolt.fill"
        }
    }
}

struct PowerUpConfig {
    var enabled: Bool = false
    var spawnInterval: TimeInterval = 15.0
    var availableTypes: [PowerUpType] = PowerUpType.allCases
}
