import SwiftUI

@main
struct OrbitPointApp: App {

    init() {
        Task { @MainActor in
            GameCenterManager.shared.authenticate()
        }
        MusicManager.shared.play()
    }

    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if let challenge = DeepLinkManager.parseChallenge(url: url) {
                        viewModel.handleChallenge(score: challenge.score, mode: challenge.mode)
                    }
                }
        }
    }
}
