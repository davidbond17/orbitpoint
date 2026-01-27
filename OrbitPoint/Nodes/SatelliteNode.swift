import SpriteKit

class SatelliteNode: SKNode {

    private let bodyNode: SKShapeNode
    private let glowNode: SKEffectNode
    private var trailNodes: [SKShapeNode] = []
    private let maxTrailNodes = 20

    var orbitCenter: CGPoint = .zero
    var orbitRadius: CGFloat = Theme.Dimensions.orbitRadius
    var angularVelocity: CGFloat = Theme.Animation.orbitSpeed
    var currentAngle: CGFloat = 0
    var isClockwise: Bool = true

    private var lastTrailTime: TimeInterval = 0
    private let trailInterval: TimeInterval = 0.03

    override init() {
        bodyNode = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius)
        bodyNode.fillColor = Theme.Colors.satelliteSK
        bodyNode.strokeColor = .clear
        bodyNode.zPosition = 20

        let glowShape = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 2)
        glowShape.fillColor = Theme.Colors.satelliteSK.withAlphaComponent(0.4)
        glowShape.strokeColor = .clear

        glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        glowNode.addChild(glowShape)
        glowNode.zPosition = 15

        super.init()

        addChild(glowNode)
        addChild(bodyNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateOrbit(deltaTime: TimeInterval, currentTime: TimeInterval) {
        let direction: CGFloat = isClockwise ? -1 : 1
        currentAngle += angularVelocity * CGFloat(deltaTime) * direction

        if currentAngle > .pi * 2 {
            currentAngle -= .pi * 2
        } else if currentAngle < 0 {
            currentAngle += .pi * 2
        }

        let x = orbitCenter.x + cos(currentAngle) * orbitRadius
        let y = orbitCenter.y + sin(currentAngle) * orbitRadius
        position = CGPoint(x: x, y: y)

        if currentTime - lastTrailTime >= trailInterval {
            spawnTrailNode()
            lastTrailTime = currentTime
        }
    }

    func reverseDirection() {
        isClockwise.toggle()
    }

    private func spawnTrailNode() {
        guard let parentNode = parent else { return }

        let trail = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 0.6)
        trail.fillColor = Theme.Colors.satelliteTrailSK
        trail.strokeColor = .clear
        trail.position = position
        trail.zPosition = 5
        trail.alpha = 0.6

        parentNode.addChild(trail)
        trailNodes.append(trail)

        let fadeOut = SKAction.fadeOut(withDuration: Theme.Animation.trailFadeDuration)
        let scaleDown = SKAction.scale(to: 0.3, duration: Theme.Animation.trailFadeDuration)
        let group = SKAction.group([fadeOut, scaleDown])
        let remove = SKAction.removeFromParent()

        trail.run(SKAction.sequence([group, remove])) { [weak self] in
            self?.trailNodes.removeAll { $0 == trail }
        }

        while trailNodes.count > maxTrailNodes {
            if let oldest = trailNodes.first {
                oldest.removeFromParent()
                trailNodes.removeFirst()
            }
        }
    }

    func clearTrails() {
        for trail in trailNodes {
            trail.removeFromParent()
        }
        trailNodes.removeAll()
    }
}
