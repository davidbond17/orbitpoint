import SwiftUI
import SpriteKit

enum ItemType: String, Codable {
    case satellite
    case sun
    case debris
    case theme
}

struct StoreItem: Identifiable {
    let id: String
    let name: String
    let type: ItemType
    let price: Int
    let previewColor: Color
    let skColor: SKColor

    var isDefault: Bool {
        price == 0
    }
}

struct ThemePack: Identifiable {
    let id: String
    let name: String
    let price: Int
    let satelliteColor: Color
    let satelliteSKColor: SKColor
    let sunCoreColor: Color
    let sunCoreSKColor: SKColor
    let sunGlowColor: Color
    let sunGlowSKColor: SKColor
    let debrisColor: Color
    let debrisSKColor: SKColor
}

enum StoreItems {
    static let satellites: [StoreItem] = [
        StoreItem(id: "satellite_cyan", name: "Cyan", type: .satellite, price: 0,
                  previewColor: Color(red: 0.4, green: 0.8, blue: 1.0),
                  skColor: SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)),
        StoreItem(id: "satellite_gold", name: "Gold", type: .satellite, price: 100,
                  previewColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                  skColor: SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)),
        StoreItem(id: "satellite_purple", name: "Purple", type: .satellite, price: 75,
                  previewColor: Color(red: 0.7, green: 0.3, blue: 0.9),
                  skColor: SKColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1.0)),
        StoreItem(id: "satellite_green", name: "Green", type: .satellite, price: 50,
                  previewColor: Color(red: 0.3, green: 0.9, blue: 0.4),
                  skColor: SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)),
        StoreItem(id: "satellite_pink", name: "Pink", type: .satellite, price: 75,
                  previewColor: Color(red: 1.0, green: 0.4, blue: 0.7),
                  skColor: SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)),
        StoreItem(id: "satellite_white", name: "White", type: .satellite, price: 150,
                  previewColor: Color.white,
                  skColor: SKColor.white)
    ]

    static let suns: [StoreItem] = [
        StoreItem(id: "sun_classic", name: "Classic", type: .sun, price: 0,
                  previewColor: Color(red: 1.0, green: 0.95, blue: 0.8),
                  skColor: SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)),
        StoreItem(id: "sun_blue", name: "Blue Giant", type: .sun, price: 150,
                  previewColor: Color(red: 0.6, green: 0.8, blue: 1.0),
                  skColor: SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)),
        StoreItem(id: "sun_red", name: "Red Dwarf", type: .sun, price: 100,
                  previewColor: Color(red: 1.0, green: 0.4, blue: 0.3),
                  skColor: SKColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0)),
        StoreItem(id: "sun_neon", name: "Neon", type: .sun, price: 300,
                  previewColor: Color(red: 0.0, green: 1.0, blue: 0.8),
                  skColor: SKColor(red: 0.0, green: 1.0, blue: 0.8, alpha: 1.0))
    ]

    static let debris: [StoreItem] = [
        StoreItem(id: "debris_red", name: "Red", type: .debris, price: 0,
                  previewColor: Color(red: 0.6, green: 0.2, blue: 0.3),
                  skColor: SKColor(red: 0.6, green: 0.2, blue: 0.3, alpha: 1.0)),
        StoreItem(id: "debris_purple", name: "Purple", type: .debris, price: 75,
                  previewColor: Color(red: 0.5, green: 0.2, blue: 0.6),
                  skColor: SKColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0)),
        StoreItem(id: "debris_green", name: "Green", type: .debris, price: 50,
                  previewColor: Color(red: 0.2, green: 0.5, blue: 0.3),
                  skColor: SKColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)),
        StoreItem(id: "debris_orange", name: "Orange", type: .debris, price: 75,
                  previewColor: Color(red: 0.8, green: 0.4, blue: 0.1),
                  skColor: SKColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 1.0))
    ]

    static let themes: [ThemePack] = [
        ThemePack(
            id: "theme_neon",
            name: "Neon Dreams",
            price: 500,
            satelliteColor: Color(red: 1.0, green: 0.4, blue: 0.7),
            satelliteSKColor: SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0),
            sunCoreColor: Color(red: 0.4, green: 0.6, blue: 1.0),
            sunCoreSKColor: SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
            sunGlowColor: Color(red: 0.3, green: 0.4, blue: 0.9),
            sunGlowSKColor: SKColor(red: 0.3, green: 0.4, blue: 0.9, alpha: 0.6),
            debrisColor: Color(red: 0.0, green: 0.8, blue: 0.8),
            debrisSKColor: SKColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1.0)
        ),
        ThemePack(
            id: "theme_solar",
            name: "Solar Flare",
            price: 400,
            satelliteColor: Color(red: 1.0, green: 0.84, blue: 0.0),
            satelliteSKColor: SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
            sunCoreColor: Color(red: 1.0, green: 0.3, blue: 0.1),
            sunCoreSKColor: SKColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1.0),
            sunGlowColor: Color(red: 1.0, green: 0.5, blue: 0.0),
            sunGlowSKColor: SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.6),
            debrisColor: Color(red: 0.9, green: 0.5, blue: 0.1),
            debrisSKColor: SKColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1.0)
        ),
        ThemePack(
            id: "theme_frozen",
            name: "Frozen Orbit",
            price: 600,
            satelliteColor: Color.white,
            satelliteSKColor: SKColor.white,
            sunCoreColor: Color(red: 0.7, green: 0.85, blue: 1.0),
            sunCoreSKColor: SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0),
            sunGlowColor: Color(red: 0.4, green: 0.7, blue: 1.0),
            sunGlowSKColor: SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6),
            debrisColor: Color(red: 0.3, green: 0.5, blue: 0.7),
            debrisSKColor: SKColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0)
        )
    ]
}
