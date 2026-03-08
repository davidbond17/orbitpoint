import AVFoundation

class VoiceLineManager {

    static let shared = VoiceLineManager()

    private var voicePlayer: AVAudioPlayer?
    private var duckTimer: Timer?

    private init() {}

    func hasVoiceLine(_ lineId: String) -> Bool {
        Bundle.main.url(forResource: "voice_\(lineId)", withExtension: "m4a") != nil ||
        Bundle.main.url(forResource: "voice_\(lineId)", withExtension: "mp3") != nil
    }

    func play(_ lineId: String, duckMusic: Bool = true) {
        guard let url = Bundle.main.url(forResource: "voice_\(lineId)", withExtension: "m4a")
                ?? Bundle.main.url(forResource: "voice_\(lineId)", withExtension: "mp3") else {
            return
        }

        do {
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = 1.0
            voicePlayer?.prepareToPlay()

            if duckMusic {
                MusicManager.shared.duckForVoice()
            }

            voicePlayer?.play()

            let duration = voicePlayer?.duration ?? 2.0
            duckTimer?.invalidate()
            duckTimer = Timer.scheduledTimer(withTimeInterval: duration + 0.3, repeats: false) { _ in
                if duckMusic {
                    MusicManager.shared.restoreFromDuck()
                }
            }
        } catch {
            print("Failed to play voice line \(lineId): \(error.localizedDescription)")
        }
    }

    func stop() {
        voicePlayer?.stop()
        voicePlayer = nil
        duckTimer?.invalidate()
        MusicManager.shared.restoreFromDuck()
    }

    func randomGameOverLine() -> String? {
        let ids = (1...6).map { "gameover_\($0)" }
        let available = ids.filter { hasVoiceLine($0) }
        return available.randomElement()
    }

    func randomCompleteLine() -> String? {
        let ids = (1...6).map { "complete_\($0)" }
        let available = ids.filter { hasVoiceLine($0) }
        return available.randomElement()
    }
}
