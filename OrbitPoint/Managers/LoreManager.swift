import Foundation

class LoreManager: ObservableObject {

    static let shared = LoreManager()

    private let collectedKey = "orbitpoint.lore.collected"

    @Published private(set) var collectedFragments: Set<String> = []

    var totalCollected: Int { collectedFragments.count }
    var totalAvailable: Int { LoreFragments.all.count }

    private init() {
        loadProgress()
    }

    func isCollected(_ id: String) -> Bool {
        collectedFragments.contains(id)
    }

    func collectFragment(_ id: String) {
        guard !collectedFragments.contains(id) else { return }
        collectedFragments.insert(id)
        saveProgress()
    }

    func hasFragmentForLevel(zone: Int, level: Int) -> Bool {
        guard let fragment = LoreFragments.fragmentForLevel(zone: zone, level: level) else { return false }
        return !collectedFragments.contains(fragment.id)
    }

    private func loadProgress() {
        if let data = UserDefaults.standard.array(forKey: collectedKey) as? [String] {
            collectedFragments = Set(data)
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(Array(collectedFragments), forKey: collectedKey)
    }
}
