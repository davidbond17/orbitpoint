import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(score: Int, isNewHighScore: Bool)
}

class GameScene: SKScene {

    weak var gameDelegate: GameSceneDelegate?

    private var starNode: StarNode!
    private var satelliteNode: SatelliteNode!
    private var debrisSpawner: DebrisSpawner!
    private var scoreLabel: SKLabelNode!

    private var lastUpdateTime: TimeInterval = 0
    private var isGameActive = false

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
    }

    func setScoreVisible(_ visible: Bool) {
        let targetAlpha: CGFloat = visible ? 1.0 : 0.0
        scoreLabel.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.2))
    }

    func startGame() {
        isGameActive = true
        lastUpdateTime = 0

        debrisSpawner.reset()
        satelliteNode.clearTrails()
        satelliteNode.currentAngle = .pi / 2
        satelliteNode.isClockwise = true

        satelliteNode.refreshColors()
        starNode.refreshColors()

        scoreLabel.text = "0"
        setScoreVisible(true)

        AudioManager.shared.playGameStart()
    }

    func stopGame() {
        isGameActive = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameActive else { return }
        satelliteNode.reverseDirection()
        HapticsManager.shared.playDirectionChange()
        AudioManager.shared.playDirectionChange()
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            ScoreManager.shared.startGame(at: currentTime)
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        satelliteNode.updateOrbit(deltaTime: deltaTime, currentTime: currentTime)

        let starPosition = starNode.position
        debrisSpawner.update(deltaTime: deltaTime, starPosition: starPosition)

        ScoreManager.shared.update(currentTime: currentTime)
        scoreLabel.text = "\(ScoreManager.shared.currentScore)"

        if debrisSpawner.checkCollisions(
            satellitePosition: satelliteNode.position,
            satelliteRadius: Theme.Dimensions.satelliteRadius
        ) {
            handleGameOver()
        }
    }

    private func handleGameOver() {
        isGameActive = false

        HapticsManager.shared.playCollision()
        AudioManager.shared.playCollision()

        let isNewHighScore = ScoreManager.shared.endGame()
        let finalScore = ScoreManager.shared.currentScore

        if isNewHighScore {
            HapticsManager.shared.playNewHighScore()
            AudioManager.shared.playNewHighScore()
        }

        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.3, duration: 0.1),
            SKAction.colorize(with: Theme.Colors.backgroundSK, colorBlendFactor: 0, duration: 0.2)
        ])
        scene?.run(flash)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.gameDelegate?.gameDidEnd(score: finalScore, isNewHighScore: isNewHighScore)
        }
    }
}
