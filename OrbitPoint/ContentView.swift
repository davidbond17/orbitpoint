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

                if viewModel.showDailyBonus {
                    DailyBonusView(isPresented: $viewModel.showDailyBonus)
                        .transition(.opacity)
                        .zIndex(10)
                }

                if let unlock = viewModel.newMilestoneUnlock {
                    MilestoneUnlockToast(item: unlock) {
                        viewModel.newMilestoneUnlock = nil
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(11)
                }

                if let fragment = viewModel.collectedLoreFragment {
                    LoreCollectedToast(fragment: fragment) {
                        viewModel.collectedLoreFragment = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(12)
                }

                if let toast = viewModel.powerUpToast {
                    PowerUpCollectedToast(type: toast) {
                        viewModel.powerUpToast = nil
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(13)
                }

                if viewModel.showLoreIntro {
                    LoreIntroView {
                        viewModel.markLoreIntroSeen()
                    }
                    .transition(.opacity)
                    .zIndex(20)
                }
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
        .sheet(isPresented: $viewModel.showCodex) {
            CodexView {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    viewModel.replayLoreIntro()
                }
            }
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
                viewModel.startFreePlay()
            }
            .transition(.opacity)
            .onAppear {
                GameCenterManager.shared.showAccessPoint(true)
            }

        case .campaignMap:
            CampaignMapView(viewModel: viewModel)
                .transition(.opacity)

        case .playing:
            VStack {
                HStack {
                    if viewModel.currentGameMode != .zen, let powerUp = viewModel.activePowerUp {
                        PowerUpHUDView(
                            powerUpType: powerUp,
                            timeRemaining: viewModel.powerUpTimeRemaining
                        )
                        .padding(.leading, 20)
                        .padding(.top, 50)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    if viewModel.currentGameMode == .zen {
                        Button {
                            viewModel.returnToMenu()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                                .frame(width: 36, height: 36)
                                .background(Theme.Colors.glassBackground.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    } else {
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
                    switch viewModel.currentGameMode {
                    case .freePlay, .zen, .dailyChallenge, .gauntlet, .timeAttack:
                        viewModel.returnToMenu()
                    case .campaign:
                        viewModel.returnToCampaignMap()
                    }
                }
            )
            .transition(.opacity)

        case .gameOver:
            GameOverView(
                score: viewModel.lastScore,
                earnedCoins: viewModel.lastEarnedCurrency,
                isNewHighScore: viewModel.isNewHighScore,
                highScore: viewModel.highScore,
                xpEarned: viewModel.lastXPEarned,
                didLevelUp: viewModel.didLevelUp,
                onPlayAgain: {
                    viewModel.startGame()
                },
                onMenu: {
                    viewModel.returnToMenu()
                }
            )
            .transition(.opacity)

        case .campaignLevelComplete:
            if let result = viewModel.lastLevelResult {
                CampaignLevelCompleteView(
                    result: result,
                    xpEarned: viewModel.lastXPEarned,
                    didLevelUp: viewModel.didLevelUp,
                    onNextLevel: {
                        let nextLevel = result.levelConfig.level + 1
                        let zone = result.levelConfig.zone
                        if CampaignLevels.level(zone: zone, level: nextLevel) != nil {
                            viewModel.startCampaignLevel(zone: zone, level: nextLevel)
                        } else {
                            viewModel.returnToCampaignMap()
                        }
                    },
                    onRetry: {
                        viewModel.startCampaignLevel(
                            zone: result.levelConfig.zone,
                            level: result.levelConfig.level
                        )
                    },
                    onMap: {
                        viewModel.returnToCampaignMap()
                    }
                )
                .transition(.opacity)
            }

        case .dailyChallengeComplete:
            DailyChallengeResultView(
                score: viewModel.lastScore,
                targetTime: Int(viewModel.dailyChallengeTargetTime),
                todaysBest: DailyChallengeManager.shared.todaysBestTime,
                streak: DailyChallengeManager.shared.currentStreak,
                coinsEarned: viewModel.dailyChallengeCoinsEarned,
                hasCompletedToday: DailyChallengeManager.shared.hasCompletedToday,
                xpEarned: viewModel.lastXPEarned,
                didLevelUp: viewModel.didLevelUp,
                onTryAgain: {
                    viewModel.startDailyChallenge()
                },
                onMenu: {
                    viewModel.returnToMenu()
                }
            )
            .transition(.opacity)

        case .gauntletComplete:
            GauntletResultView(
                rounds: viewModel.lastGauntletRounds,
                totalTime: viewModel.lastScore,
                coinsEarned: viewModel.lastEarnedCurrency,
                xpEarned: viewModel.lastXPEarned,
                didLevelUp: viewModel.didLevelUp,
                onPlayAgain: {
                    viewModel.startGauntlet()
                },
                onMenu: {
                    viewModel.returnToMenu()
                }
            )
            .transition(.opacity)

        case .timeAttackComplete:
            TimeAttackResultView(
                timeSurvived: Int(viewModel.lastTimeAttackTime),
                completed: viewModel.lastTimeAttackCompleted,
                coinsEarned: viewModel.lastEarnedCurrency,
                xpEarned: viewModel.lastXPEarned,
                didLevelUp: viewModel.didLevelUp,
                onPlayAgain: {
                    viewModel.startTimeAttack()
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

    func campaignLevelDidEnd(result: LevelResult) {
        Task { @MainActor in
            viewModel.handleCampaignLevelEnd(result: result)
        }
    }

    func loreFragmentCollected(id: String) {
        Task { @MainActor in
            viewModel.handleLoreFragmentCollected(id: id)
        }
    }

    func powerUpCollected(type: PowerUpType) {
        Task { @MainActor in
            viewModel.handlePowerUpCollected(type: type)
        }
    }

    func powerUpExpired() {
        Task { @MainActor in
            viewModel.handlePowerUpExpired()
        }
    }

    func shieldBroken() {
        Task { @MainActor in
            viewModel.handleShieldBroken()
        }
    }

    func powerUpTimeUpdated(remaining: TimeInterval) {
        Task { @MainActor in
            viewModel.powerUpTimeRemaining = remaining
        }
    }
}

#Preview {
    ContentView()
}
