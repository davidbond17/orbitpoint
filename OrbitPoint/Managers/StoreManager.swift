import SwiftUI
import SpriteKit

class StoreManager: ObservableObject {

    static let shared = StoreManager()

    private let unlockedKey = "orbitpoint.unlocked"
    private let equippedSatelliteKey = "orbitpoint.equipped.satellite"
    private let equippedSunKey = "orbitpoint.equipped.sun"
    private let equippedDebrisKey = "orbitpoint.equipped.debris"

    @Published private(set) var unlockedItems: Set<String> = []
    @Published var equippedSatelliteId: String = "satellite_cyan"
    @Published var equippedSunId: String = "sun_classic"
    @Published var equippedDebrisId: String = "debris_red"

    var currentSatelliteColor: SKColor {
        if let item = StoreItems.satellites.first(where: { $0.id == equippedSatelliteId }) {
            return item.skColor
        }
        return Theme.Colors.satelliteSK
    }

    var currentSunCoreColor: SKColor {
        if let theme = StoreItems.themes.first(where: { unlockedItems.contains($0.id) && isThemeEquipped($0) }) {
            return theme.sunCoreSKColor
        }
        if let item = StoreItems.suns.first(where: { $0.id == equippedSunId }) {
            return item.skColor
        }
        return Theme.Colors.starCoreSK
    }

    var currentSunGlowColor: SKColor {
        if let theme = StoreItems.themes.first(where: { unlockedItems.contains($0.id) && isThemeEquipped($0) }) {
            return theme.sunGlowSKColor
        }
        return Theme.Colors.starGlowSK
    }

    var currentDebrisColor: SKColor {
        if let item = StoreItems.debris.first(where: { $0.id == equippedDebrisId }) {
            return item.skColor
        }
        return Theme.Colors.debrisSK
    }

    private init() {
        loadUnlockedItems()
        loadEquippedItems()

        for item in StoreItems.satellites where item.isDefault {
            unlockedItems.insert(item.id)
        }
        for item in StoreItems.suns where item.isDefault {
            unlockedItems.insert(item.id)
        }
        for item in StoreItems.debris where item.isDefault {
            unlockedItems.insert(item.id)
        }
    }

    private func isThemeEquipped(_ theme: ThemePack) -> Bool {
        let satelliteMatch = StoreItems.satellites.first(where: { $0.id == equippedSatelliteId })
        return satelliteMatch?.skColor == theme.satelliteSKColor
    }

    func isUnlocked(_ itemId: String) -> Bool {
        unlockedItems.contains(itemId)
    }

    func purchase(_ item: StoreItem) -> Bool {
        guard !unlockedItems.contains(item.id) else { return true }
        guard ScoreManager.shared.spendCurrency(item.price) else { return false }

        unlockedItems.insert(item.id)
        saveUnlockedItems()
        equip(item)
        return true
    }

    func purchaseTheme(_ theme: ThemePack) -> Bool {
        guard !unlockedItems.contains(theme.id) else { return true }
        guard ScoreManager.shared.spendCurrency(theme.price) else { return false }

        unlockedItems.insert(theme.id)
        saveUnlockedItems()
        equipTheme(theme)
        return true
    }

    func equip(_ item: StoreItem) {
        guard unlockedItems.contains(item.id) || item.isDefault else { return }

        switch item.type {
        case .satellite:
            equippedSatelliteId = item.id
            UserDefaults.standard.set(item.id, forKey: equippedSatelliteKey)
        case .sun:
            equippedSunId = item.id
            UserDefaults.standard.set(item.id, forKey: equippedSunKey)
        case .debris:
            equippedDebrisId = item.id
            UserDefaults.standard.set(item.id, forKey: equippedDebrisKey)
        case .theme:
            break
        }

        objectWillChange.send()
    }

    func equipTheme(_ theme: ThemePack) {
        guard unlockedItems.contains(theme.id) else { return }

        if let satellite = StoreItems.satellites.first(where: { $0.skColor == theme.satelliteSKColor }) {
            equippedSatelliteId = satellite.id
            UserDefaults.standard.set(satellite.id, forKey: equippedSatelliteKey)
        }

        objectWillChange.send()
    }

    private func loadUnlockedItems() {
        if let data = UserDefaults.standard.array(forKey: unlockedKey) as? [String] {
            unlockedItems = Set(data)
        }
    }

    private func saveUnlockedItems() {
        UserDefaults.standard.set(Array(unlockedItems), forKey: unlockedKey)
    }

    private func loadEquippedItems() {
        if let id = UserDefaults.standard.string(forKey: equippedSatelliteKey) {
            equippedSatelliteId = id
        }
        if let id = UserDefaults.standard.string(forKey: equippedSunKey) {
            equippedSunId = id
        }
        if let id = UserDefaults.standard.string(forKey: equippedDebrisKey) {
            equippedDebrisId = id
        }
    }
}
