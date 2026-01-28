import AVFoundation

class MusicManager {

    static let shared = MusicManager()

    private var audioPlayer: AVAudioPlayer?
    private let musicVolumeKey = "musicVolume"

    var volume: Float {
        get { UserDefaults.standard.float(forKey: musicVolumeKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: musicVolumeKey)
            audioPlayer?.volume = newValue
        }
    }

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    private var isMusicEnabled: Bool {
        volume > 0
    }

    private init() {
        UserDefaults.standard.register(defaults: [musicVolumeKey: 0.5])
        setupAudioSession()
        loadMusic()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    private func loadMusic() {
        guard let url = Bundle.main.url(forResource: "theme", withExtension: "mp3") else {
            print("Music file not found. Add 'theme.mp3' to the project.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to load background music: \(error.localizedDescription)")
        }
    }

    func play() {
        guard audioPlayer != nil else { return }
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }

    func setVolume(_ value: Float) {
        volume = max(0, min(1, value))
    }

    func fadeIn(duration: TimeInterval = 1.0) {
        guard let player = audioPlayer else { return }

        player.volume = 0
        player.play()

        let steps = 20
        let volumeIncrement = volume / Float(steps)
        let stepDuration = duration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) { [weak self] in
                guard let self = self else { return }
                player.volume = min(volumeIncrement * Float(i), self.volume)
            }
        }
    }

    func fadeOut(duration: TimeInterval = 1.0) {
        guard let player = audioPlayer, player.isPlaying else { return }

        let currentVolume = player.volume
        let steps = 20
        let volumeDecrement = currentVolume / Float(steps)
        let stepDuration = duration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                let newVolume = currentVolume - volumeDecrement * Float(i)
                player.volume = max(0, newVolume)

                if i == steps {
                    player.pause()
                    player.volume = currentVolume
                }
            }
        }
    }
}
