import SwiftUI

@main
struct OrbitPointApp: App {

    init() {
        Task { @MainActor in
            GameCenterManager.shared.authenticate()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
