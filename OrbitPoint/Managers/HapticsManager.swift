import UIKit

class HapticsManager {

    static let shared = HapticsManager()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }

    private init() {
        UserDefaults.standard.register(defaults: ["hapticsEnabled": true])
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
    }

    func playTap() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }

    func playDirectionChange() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }

    func playCollision() {
        guard isEnabled else { return }
        heavyGenerator.impactOccurred()
        notificationGenerator.notificationOccurred(.error)
    }

    func playNewHighScore() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func playButtonPress() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.6)
    }
}
