import AVFoundation
import AudioToolbox

class AudioManager {

    static let shared = AudioManager()

    private var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "soundEnabled")
    }

    private init() {
        UserDefaults.standard.register(defaults: ["soundEnabled": true])
    }

    func playDirectionChange() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playCollision() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1521)
    }

    func playNewHighScore() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    func playButtonTap() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playGameStart() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(1113)
    }
}
