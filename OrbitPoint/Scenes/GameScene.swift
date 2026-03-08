import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(score: Int, isNewHighScore: Bool)
    func campaignLevelDidEnd(result: LevelResult)
    func loreFragmentCollected(id: String)
    func powerUpCollected(type: PowerUpType)
    func powerUpExpired()
    func shieldBroken()
    func powerUpTimeUpdated(remaining: TimeInterval)
}

class GameScene: SKScene {

    weak var gameDelegate: GameSceneDelegate?

    private var starNode: StarNode!
    private var satelliteNode: SatelliteNode!
    private var debrisSpawner: DebrisSpawner!
    private var powerUpManager: PowerUpManager!
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
    private var bonusScoreAccumulator: TimeInterval = 0
    private var previousPowerUp: PowerUpType?
    private var currentOrbitRadius: CGFloat = Theme.Dimensions.orbitRadius
    private var multiOrbitEnabled: Bool = true
    private var innerOrbitPath: SKShapeNode?
    private var outerOrbitPath: SKShapeNode?

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
        setupGestureRecognizers()
    }

    private func setupScene() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        let starfield = StarfieldNode(size: size)
        addChild(starfield)

        starNode = StarNode()
        starNode.position = center
        addChild(starNode)

        currentOrbitRadius = Theme.Dimensions.orbitRadius
        satelliteNode = SatelliteNode()
        satelliteNode.orbitCenter = center
        satelliteNode.orbitRadius = currentOrbitRadius
        satelliteNode.targetOrbitRadius = currentOrbitRadius
        satelliteNode.currentAngle = .pi / 2
        addChild(satelliteNode)

        setupOrbitPaths(center: center)

        debrisSpawner = DebrisSpawner(scene: self)
        powerUpManager = PowerUpManager(scene: self)

        setupScoreLabel()
    }

    private func setupOrbitPaths(center: CGPoint) {
        innerOrbitPath?.removeFromParent()
        outerOrbitPath?.removeFromParent()

        let innerPath = CGMutablePath()
        innerPath.addArc(center: center, radius: Theme.Dimensions.innerOrbitRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        let innerNode = SKShapeNode(path: innerPath)
        innerNode.strokeColor = SKColor.white
        innerNode.lineWidth = 1
        innerNode.zPosition = 1
        innerNode.alpha = 0.08
        addChild(innerNode)
        innerOrbitPath = innerNode

        let outerPath = CGMutablePath()
        outerPath.addArc(center: center, radius: Theme.Dimensions.outerOrbitRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        let outerNode = SKShapeNode(path: outerPath)
        outerNode.strokeColor = SKColor.white
        outerNode.lineWidth = 1
        outerNode.zPosition = 1
        outerNode.alpha = 0.08
        addChild(outerNode)
        outerOrbitPath = outerNode
    }

    private func setupGestureRecognizers() {
        guard let view = view else { return }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)

        tap.require(toFail: swipeUp)
        tap.require(toFail: swipeDown)
    }

    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
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

    @objc private func handleSwipeUp(_ recognizer: UISwipeGestureRecognizer) {
        guard isGameActive, multiOrbitEnabled else { return }
        switchOrbit(to: Theme.Dimensions.outerOrbitRadius)
    }

    @objc private func handleSwipeDown(_ recognizer: UISwipeGestureRecognizer) {
        guard isGameActive, multiOrbitEnabled else { return }
        switchOrbit(to: Theme.Dimensions.innerOrbitRadius)
    }

    private func switchOrbit(to radius: CGFloat) {
        guard radius != currentOrbitRadius else { return }
        currentOrbitRadius = radius
        satelliteNode.switchToOrbit(radius: radius)
        HapticsManager.shared.playDirectionChange()
        AudioManager.shared.playDirectionChange()
    }

    private func updateOrbitHighlights() {
        guard multiOrbitEnabled else {
            innerOrbitPath?.alpha = 0
            outerOrbitPath?.alpha = 0
            return
        }

        let isOnInner = currentOrbitRadius == Theme.Dimensions.innerOrbitRadius
        let activeAlpha: CGFloat = 0.2
        let inactiveAlpha: CGFloat = 0.08

        let targetInner: CGFloat = isOnInner ? activeAlpha : inactiveAlpha
        let targetOuter: CGFloat = isOnInner ? inactiveAlpha : activeAlpha

        innerOrbitPath?.alpha += (targetInner - (innerOrbitPath?.alpha ?? 0)) * 0.15
        outerOrbitPath?.alpha += (targetOuter - (outerOrbitPath?.alpha ?? 0)) * 0.15
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

        targetTimeLabel = SKLabelNode(fontNamed: "SF Pro Rounded")
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
            multiOrbitEnabled = true
            debrisSpawner.configure(with: .standard)
            powerUpManager.configure(with: PowerUpConfig(enabled: true, spawnInterval: 15.0))
        case .campaign(let zone, let level):
            levelConfig = CampaignLevels.level(zone: zone, level: level)
            if let config = levelConfig {
                multiOrbitEnabled = config.debrisConfig.multiOrbitEnabled
                debrisSpawner.configure(with: config.debrisConfig)
                powerUpManager.configure(with: config.debrisConfig.powerUps)
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
        powerUpManager.reset()
        bonusScoreAccumulator = 0
        previousPowerUp = nil
        if let config = levelConfig {
            debrisSpawner.configure(with: config.debrisConfig)
            powerUpManager.configure(with: config.debrisConfig.powerUps)
        } else {
            powerUpManager.configure(with: PowerUpConfig(enabled: true, spawnInterval: 15.0))
        }

        satelliteNode.clearTrails()
        satelliteNode.currentAngle = .pi / 2
        satelliteNode.isClockwise = true

        if multiOrbitEnabled {
            currentOrbitRadius = Theme.Dimensions.innerOrbitRadius
            satelliteNode.orbitRadius = currentOrbitRadius
            satelliteNode.targetOrbitRadius = currentOrbitRadius
        } else {
            currentOrbitRadius = Theme.Dimensions.orbitRadius
            satelliteNode.orbitRadius = currentOrbitRadius
            satelliteNode.targetOrbitRadius = currentOrbitRadius
        }

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
        powerUpManager.reset()
    }

    func pauseScene() {
        ScoreManager.shared.pause(at: lastUpdateTime)
        isPaused = true
    }

    func resumeScene() {
        lastUpdateTime = 0
        isPaused = false
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
        updateOrbitHighlights()

        let starPosition = starNode.position
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        debrisSpawner.debrisSpeedMultiplier = powerUpManager.debrisSpeedMultiplier
        debrisSpawner.orbitRadii = multiOrbitEnabled
            ? [Theme.Dimensions.innerOrbitRadius, Theme.Dimensions.outerOrbitRadius]
            : nil
        debrisSpawner.update(deltaTime: deltaTime, starPosition: starPosition)

        let powerUpRadii: [CGFloat]? = multiOrbitEnabled
            ? [Theme.Dimensions.innerOrbitRadius, Theme.Dimensions.outerOrbitRadius]
            : nil
        powerUpManager.update(deltaTime: deltaTime, center: center, orbitRadius: currentOrbitRadius, orbitRadii: powerUpRadii)

        if let collected = powerUpManager.checkCollection(
            satellitePosition: satelliteNode.position,
            satelliteRadius: Theme.Dimensions.satelliteRadius
        ) {
            powerUpManager.activate(collected)
            applyPowerUpVisual(collected)
            HapticsManager.shared.playPowerUpCollected()
            AudioManager.shared.playPowerUpCollected()
            gameDelegate?.powerUpCollected(type: collected)
        }

        if let active = powerUpManager.activePowerUp {
            gameDelegate?.powerUpTimeUpdated(remaining: powerUpManager.activeTimeRemaining)
            if active == .orbitBoost {
                bonusScoreAccumulator += deltaTime
            }
        } else if previousPowerUp != nil {
            removePowerUpVisual(previousPowerUp!)
            gameDelegate?.powerUpExpired()
        }
        previousPowerUp = powerUpManager.activePowerUp

        ScoreManager.shared.update(currentTime: currentTime)
        let displayScore = ScoreManager.shared.currentScore + Int(bonusScoreAccumulator)
        scoreLabel.text = "\(displayScore)"

        if let config = levelConfig {
            updateCampaignTargetLabel(config: config)
        }

        spawnLoreFragmentIfNeeded()
        checkLoreFragmentCollection()

        if debrisSpawner.checkCollisions(
            satellitePosition: satelliteNode.position,
            satelliteRadius: Theme.Dimensions.satelliteRadius
        ) {
            if powerUpManager.isPhaseShiftActive {
                // Intangible — ignore collision
            } else if powerUpManager.isShieldActive {
                powerUpManager.consumeShield()
                removePowerUpVisual(.shield)
                previousPowerUp = nil
                HapticsManager.shared.playShieldBreak()
                AudioManager.shared.playShieldBreak()
                gameDelegate?.shieldBroken()
            } else {
                handleGameOver()
            }
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
        let spawnRadius: CGFloat = multiOrbitEnabled
            ? [Theme.Dimensions.innerOrbitRadius, Theme.Dimensions.outerOrbitRadius].randomElement()!
            : Theme.Dimensions.orbitRadius
        let node = LoreFragmentNode(fragmentId: fragment.id)
        node.position = CGPoint(
            x: center.x + cos(angle) * spawnRadius,
            y: center.y + sin(angle) * spawnRadius
        )
        addChild(node)
        loreFragmentNode = node
    }

    private func checkLoreFragmentCollection() {
        guard let node = loreFragmentNode, !node.isCollected else { return }
        let collectRadius = powerUpManager.effectiveCollectRadius
        if node.checkCollection(with: satelliteNode.position, satelliteRadius: collectRadius) {
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

    // MARK: - Power-Up Visuals

    private func applyPowerUpVisual(_ type: PowerUpType) {
        if let prev = previousPowerUp, prev != type {
            removePowerUpVisual(prev)
        }
        switch type {
        case .shield:
            satelliteNode.showShieldEffect()
        case .phaseShift:
            satelliteNode.showPhaseShift()
        case .orbitBoost:
            satelliteNode.showOrbitBoost()
        case .slowField, .magnet:
            break
        }
    }

    private func removePowerUpVisual(_ type: PowerUpType) {
        switch type {
        case .shield:
            satelliteNode.removeShieldEffect()
        case .phaseShift:
            satelliteNode.removePhaseShift()
        case .orbitBoost:
            satelliteNode.removeOrbitBoost()
        case .slowField, .magnet:
            break
        }
    }
}
