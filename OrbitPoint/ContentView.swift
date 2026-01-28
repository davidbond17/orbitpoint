import SwiftUI
import SpriteKit

struct ContentView: View {

    @StateObject private var viewModel = GameViewModel()
    @State private var gameScene: GameScene?
    @State private var delegateAdapter: GameSceneDelegateAdapter?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteView(scene: makeScene(size: geometry.size))
                    .ignoresSafeArea()

                overlayView
            }
        }
        .background(Theme.Colors.background)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showLeaderboard) {
            LeaderboardView(
                highScore: viewModel.highScore,
                onShowGameCenter: {
                    viewModel.showLeaderboard = false
                    viewModel.showGameCenterLeaderboard()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showStore) {
            StoreView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showHowToPlay) {
            HowToPlayView {
                viewModel.markTutorialSeen()
                viewModel.showHowToPlay = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.checkFirstLaunch()
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.gameState {
        case .menu:
            MainMenuView(viewModel: viewModel) {
                viewModel.startGame()
            }
            .transition(.opacity)
            .onAppear {
                GameCenterManager.shared.showAccessPoint(true)
            }

        case .playing:
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.pauseGame()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(Theme.Colors.glassBackground)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50)
                }
                Spacer()
            }

        case .paused:
            PauseMenuView(
                viewModel: viewModel,
                onResume: {
                    viewModel.resumeGame()
                },
                onQuit: {
                    viewModel.returnToMenu()
                }
            )
            .transition(.opacity)

        case .gameOver:
            GameOverView(
                score: viewModel.lastScore,
                earnedCoins: viewModel.lastEarnedCurrency,
                isNewHighScore: viewModel.isNewHighScore,
                highScore: viewModel.highScore,
                onPlayAgain: {
                    viewModel.startGame()
                },
                onMenu: {
                    viewModel.returnToMenu()
                }
            )
            .transition(.opacity)
        }
    }

    private func makeScene(size: CGSize) -> GameScene {
        if let existingScene = gameScene {
            return existingScene
        }

        let scene = GameScene(size: size)
        let adapter = GameSceneDelegateAdapter(viewModel: viewModel)
        scene.gameDelegate = adapter
        viewModel.setGameScene(scene)

        DispatchQueue.main.async {
            self.gameScene = scene
            self.delegateAdapter = adapter
        }

        return scene
    }
}

class GameSceneDelegateAdapter: GameSceneDelegate {

    private let viewModel: GameViewModel

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }

    func gameDidEnd(score: Int, isNewHighScore: Bool) {
        Task { @MainActor in
            viewModel.handleGameOver(score: score, isNewHighScore: isNewHighScore)
        }
    }
}

#Preview {
    ContentView()
}
