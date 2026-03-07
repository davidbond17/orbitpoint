import SwiftUI
import SpriteKit

struct ZoneTheme {
    let zoneNumber: Int
    let name: String
    let subtitle: String
    let description: String
    let iconName: String
    let accentColor: Color
    let accentSKColor: SKColor
    let starfieldTint: SKColor
    let nebulaColors: [SKColor]
    let requiredStars: Int
}

enum ZoneThemes {
    static let all: [ZoneTheme] = [zone1, zone2, zone3, zone4, zone5]

    static let zone1 = ZoneTheme(
        zoneNumber: 1,
        name: "Sol's Edge",
        subtitle: "Calibration Sector",
        description: "Begin your mission at the edge of the SOL-7 system. Debris density is minimal — a perfect training ground for orbital maneuvers.",
        iconName: "sun.max.fill",
        accentColor: Color(red: 0.4, green: 0.8, blue: 1.0),
        accentSKColor: SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),
        starfieldTint: SKColor(white: 1.0, alpha: 1.0),
        nebulaColors: [
            SKColor(red: 0.3, green: 0.2, blue: 0.5, alpha: 0.06),
            SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.05),
            SKColor(red: 0.4, green: 0.2, blue: 0.4, alpha: 0.04)
        ],
        requiredStars: 0
    )

    static let zone2 = ZoneTheme(
        zoneNumber: 2,
        name: "Crimson Nebula",
        subtitle: "Debris Waves",
        description: "SOL-7's emissions are destabilizing the Crimson Nebula. Debris patterns are organized — almost as if something is directing them.",
        iconName: "flame.fill",
        accentColor: Color(red: 1.0, green: 0.4, blue: 0.3),
        accentSKColor: SKColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0),
        starfieldTint: SKColor(red: 1.0, green: 0.85, blue: 0.8, alpha: 1.0),
        nebulaColors: [
            SKColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0.08),
            SKColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 0.06),
            SKColor(red: 0.4, green: 0.1, blue: 0.2, alpha: 0.05)
        ],
        requiredStars: 15
    )

    static let zone3 = ZoneTheme(
        zoneNumber: 3,
        name: "Frozen Expanse",
        subtitle: "Accelerated Orbit",
        description: "Thermal readings dropping. The ice is not natural — it's crystallized starlight. Something drained this sector long before we arrived.",
        iconName: "snowflake",
        accentColor: Color(red: 0.6, green: 0.85, blue: 1.0),
        accentSKColor: SKColor(red: 0.6, green: 0.85, blue: 1.0, alpha: 1.0),
        starfieldTint: SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0),
        nebulaColors: [
            SKColor(red: 0.2, green: 0.3, blue: 0.6, alpha: 0.07),
            SKColor(red: 0.1, green: 0.4, blue: 0.6, alpha: 0.05),
            SKColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 0.04)
        ],
        requiredStars: 30
    )

    static let zone4 = ZoneTheme(
        zoneNumber: 4,
        name: "Void Rift",
        subtitle: "Gravitational Anomalies",
        description: "Spacetime is fractured here. The debris moves against physics. Your readings are being logged but we cannot guarantee retrieval.",
        iconName: "circle.dashed",
        accentColor: Color(red: 0.7, green: 0.3, blue: 0.9),
        accentSKColor: SKColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1.0),
        starfieldTint: SKColor(red: 0.9, green: 0.8, blue: 1.0, alpha: 1.0),
        nebulaColors: [
            SKColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 0.08),
            SKColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.06),
            SKColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 0.05)
        ],
        requiredStars: 50
    )

    static let zone5 = ZoneTheme(
        zoneNumber: 5,
        name: "Supernova Core",
        subtitle: "Final Stand",
        description: "SOL-7 is going critical. All remaining probe units have been lost. You are the last. Every second you hold orbit delays the inevitable.",
        iconName: "sparkles",
        accentColor: Color(red: 1.0, green: 0.9, blue: 0.4),
        accentSKColor: SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0),
        starfieldTint: SKColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0),
        nebulaColors: [
            SKColor(red: 0.6, green: 0.4, blue: 0.1, alpha: 0.08),
            SKColor(red: 0.5, green: 0.3, blue: 0.1, alpha: 0.07),
            SKColor(red: 0.7, green: 0.5, blue: 0.2, alpha: 0.05)
        ],
        requiredStars: 70
    )

    static func theme(for zone: Int) -> ZoneTheme {
        all.first { $0.zoneNumber == zone } ?? zone1
    }
}
