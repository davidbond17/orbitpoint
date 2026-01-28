import SwiftUI

@main
struct OrbitPointApp: App {

    init() {
        Task { @MainActor in
            GameCenterManager.shared.authenticate()
        }
        MusicManager.shared.play()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
