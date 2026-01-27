import SpriteKit

class GameScene: SKScene {

    private var starNode: StarNode!
    private var satelliteNode: SatelliteNode!
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
        startGame()
    }

    private func setupScene() {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        starNode = StarNode()
        starNode.position = center
        addChild(starNode)

        satelliteNode = SatelliteNode()
        satelliteNode.orbitCenter = center
        satelliteNode.orbitRadius = Theme.Dimensions.orbitRadius
        satelliteNode.currentAngle = .pi / 2
        addChild(satelliteNode)

        drawOrbitPath(center: center, radius: Theme.Dimensions.orbitRadius)
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

    func startGame() {
        isGameActive = true
        lastUpdateTime = 0
    }

    func stopGame() {
        isGameActive = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameActive else { return }
        satelliteNode.reverseDirection()
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameActive else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        satelliteNode.updateOrbit(deltaTime: deltaTime, currentTime: currentTime)
    }
}
