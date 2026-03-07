import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(score: Int, isNewHighScore: Bool)
    func campaignLevelDidEnd(result: LevelResult)
    func loreFragmentCollected(id: String)
}

class GameScene: SKScene {

    weak var gameDelegate: GameSceneDelegate?

    private var starNode: StarNode!
    private var satelliteNode: SatelliteNode!
    private var debrisSpawner: DebrisSpawner!
    private var scoreLabel: SKLabelNode!
    private var targetTimeLabel: SKLabelNode!

    private var lastUpdateTime: TimeInterval = 0
    private var isGameActive = false

    private var gameMode: GameMode = .freePlay
    private var levelConfig: LevelConfig?
    private var reverseCount: Int = 0
    private var timeSinceLastReverse: TimeInterval = 0
    private var longestNoReverseDuration: TimeInterval = 0
    private var gameElapsedTime: TimeInterval = 0
    private var loreFragmentNode: LoreFragmentNode?
    private var loreSpawnTime: TimeInterval = 0
    private var hasSpawnedLoreFragment = false

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = Theme.Colors.backgroundSK
        setupScene()
    }

    private func setupScene() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        let starfield = StarfieldNode(size: size)
        addChild(starfield)

        starNode = StarNode()
        starNode.position = center
        addChild(starNode)

        satelliteNode = SatelliteNode()
        satelliteNode.orbitCenter = center
        satelliteNode.orbitRadius = Theme.Dimensions.orbitRadius
        satelliteNode.currentAngle = .pi / 2
        addChild(satelliteNode)

        drawOrbitPath(center: center, radius: Theme.Dimensions.orbitRadius)

        debrisSpawner = DebrisSpawner(scene: self)

        setupScoreLabel()
    }

    private func drawOrbitPath(center: CGPoint, radius: CGFloat) {
        let path = CGMutablePath()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )

        let orbitPath = SKShapeNode(path: path)
        orbitPath.strokeColor = SKColor.white.withAlphaComponent(0.1)
        orbitPath.lineWidth = 1
        orbitPath.zPosition = 1
        addChild(orbitPath)
    }

    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "SF Pro Rounded")
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "0"
        scoreLabel.alpha = 0
        addChild(scoreLabel)

        targetTimeLabel = SKLabelNode(f
                                      ontNamed: "SF Pro Rounded")
        targetTimeLabel.fontSize = 16
        targetTimeLabel.fontColor = SKColor(white: 1.0, alpha: 0.5)
        targetTimeLabel.position = CGPoint(x: size.width / 2, y: size.height - 148)
        targetTimeLabel.zPosition = 100
        targetTimeLabel.horizontalAlignmentMode = .center
        targetTimeLabel.text = ""
        targetTimeLabel.alpha = 0
        addChild(targetTimeLabel)
    }

    func configureForMode(_ mode: GameMode) {
        gameMode = mode
        switch mode {
        case .freePlay:
            levelConfig = nil
            debrisSpawner.configure(with: .standard)
        case .campaign(let zone, let level):
            levelConfig = CampaignLevels.level(zone: zone, level: level)
            if let config = levelConfig {
                debrisSpawner.configure(with: config.debrisConfig)
            }
        }
    }

    func setScoreVisible(_ visible: Bool) {
        let targetAlpha: CGFloat = visible ? 1.0 : 0.0
        scoreLabel.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.2))
    }

    func startGame() {
        isGameActive = true
        lastUpdateTime = 0
        reverseCount = 0
        timeSinceLastReverse = 0
        longestNoReverseDuration = 0
        gameElapsedTime = 0

        debrisSpawner.reset()
        if let config = levelConfig {
            debrisSpawner.configure(with: config.debrisConfig)
        }

        satelliteNode.clearTrails()
        satelliteNode.currentAngle = .pi / 2
        satelliteNode.isClockwise = true

        satelliteNode.refreshColors()
        starNode.refreshColors()

        scoreLabel.text = "0"
        setScoreVisible(true)

        targetTimeLabel.fontColor = SKColor(white: 1.0, alpha: 0.5)
        if let config = levelConfig {
            targetTimeLabel.text = "Target: \(Int(config.targetTime))s"
            targetTimeLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
        } else {
            targetTimeLabel.text = ""
            targetTimeLabel.alpha = 0
        }

        loreFragmentNode?.removeFromParent()
        loreFragmentNode = nil
        hasSpawnedLoreFragment = false
        if case .campaign(let zone, let level) = gameMode {
            if LoreManager.shared.hasFragmentForLevel(zone: zone, level: level) {
                loreSpawnTime = TimeInterval.random(in: 5...15)
            }
        }

        AudioManager.shared.playGameStart()
    }

    func stopGame() {
        isGameActive = false
    }

    func pauseScene() {
        ScoreManager.shared.pause(at: lastUpdateTime)
        isPaused = true
    }

    func resumeScene() {
        lastUpdateTime = 0
        isPaused = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameActive else { return }
        satelliteNode.reverseDirection()
        reverseCount += 1
        if timeSinceLastReverse > longestNoReverseDuration {
            longestNoReverseDuration = timeSinceLastReverse
        }
        timeSinceLastReverse = 0
        HapticsManager.shared.playDirectionChange()
        AudioManager.shared.playDirectionChange()
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        if lastUpdateTime == 0 {
            if ScoreManager.shared.currentScore == 0 {
                ScoreManager.shared.startGame(at: currentTime)
            } else {
                ScoreManager.shared.resume(at: currentTime)
            }
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        gameElapsedTime += deltaTime
        timeSinceLastReverse += deltaTime

        satelliteNode.updateOrbit(deltaTime: deltaTime, currentTime: currentTime)

        let starPosition = starNode.position
        debrisSpawner.update(deltaTime: deltaTime, starPosition: starPosition)

        ScoreManager.shared.update(currentTime: currentTime)
        scoreLabel.text = "\(ScoreManager.shared.currentScore)"

        if let config = levelConfig {
            updateCampaignTargetLabel(config: config)
        }

        spawnLoreFragmentIfNeeded()
        checkLoreFragmentCollection()

        if debrisSpawner.checkCollisions(
            satellitePosition: satelliteNode.position,
            satelliteRadius: Theme.Dimensions.satelliteRadius
        ) {
            handleGameOver()
        }
    }

    private func updateCampaignTargetLabel(config: LevelConfig) {
        let remaining = max(0, config.targetTime - gameElapsedTime)
        if remaining > 0 {
            targetTimeLabel.text = "Target: \(Int(ceil(remaining)))s"
        } else {
            targetTimeLabel.text = "Target reached!"
            targetTimeLabel.fontColor = SKColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)
        }
    }

    private func handleGameOver() {
        isGameActive = false

        if timeSinceLastReverse > longestNoReverseDuration {
            longestNoReverseDuration = timeSinceLastReverse
        }

        HapticsManager.shared.playCollision()
        AudioManager.shared.playCollision()

        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.3, duration: 0.1),
            SKAction.colorize(with: Theme.Colors.backgroundSK, colorBlendFactor: 0, duration: 0.2)
        ])
        scene?.run(flash)

        targetTimeLabel.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

        if let config = levelConfig {
            let bonusCompleted = checkBonusObjective(config: config)
            let result = LevelResult(
                levelConfig: config,
                survivalTime: gameElapsedTime,
                earnedCoins: 0,
                starsEarned: 0,
                bonusCompleted: bonusCompleted,
                reverseCount: reverseCount
            )

            let coins = CampaignManager.shared.coinReward(for: result)
            let stars = CampaignManager.shared.calculateStars(for: result)
            let finalResult = LevelResult(
                levelConfig: config,
                survivalTime: gameElapsedTime,
                earnedCoins: coins,
                starsEarned: stars,
                bonusCompleted: bonusCompleted,
                reverseCount: reverseCount
            )

            if finalResult.passed {
                ScoreManager.shared.addCurrency(coins)
                CampaignManager.shared.completeLevel(finalResult)
            }

            _ = ScoreManager.shared.endGame()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.gameDelegate?.campaignLevelDidEnd(result: finalResult)
            }
        } else {
            let isNewHighScore = ScoreManager.shared.endGame()
            let finalScore = ScoreManager.shared.currentScore

            if isNewHighScore {
                HapticsManager.shared.playNewHighScore()
                AudioManager.shared.playNewHighScore()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.gameDelegate?.gameDidEnd(score: finalScore, isNewHighScore: isNewHighScore)
            }
        }
    }

    private func spawnLoreFragmentIfNeeded() {
        guard !hasSpawnedLoreFragment,
              case .campaign(let zone, let level) = gameMode,
              gameElapsedTime >= loreSpawnTime,
              let fragment = LoreFragments.fragmentForLevel(zone: zone, level: level),
              !LoreManager.shared.isCollected(fragment.id) else { return }

        hasSpawnedLoreFragment = true
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
        let node = LoreFragmentNode(fragmentId: fragment.id)
        node.position = CGPoint(
            x: center.x + cos(angle) * Theme.Dimensions.orbitRadius,
            y: center.y + sin(angle) * Theme.Dimensions.orbitRadius
        )
        addChild(node)
        loreFragmentNode = node
    }

    private func checkLoreFragmentCollection() {
        guard let node = loreFragmentNode, !node.isCollected else { return }
        if node.checkCollection(with: satelliteNode.position, satelliteRadius: Theme.Dimensions.satelliteRadius) {
            loreFragmentNode = nil
            HapticsManager.shared.playButtonPress()
            gameDelegate?.loreFragmentCollected(id: node.fragmentId)
        }
    }

    private func checkBonusObjective(config: LevelConfig) -> Bool {
        guard let bonus = config.bonusObjective else { return false }
        switch bonus {
        case .reverseCount(let target):
            return reverseCount >= target
        case .noReverseFor(let seconds):
            return longestNoReverseDuration >= seconds
        }
    }
}
