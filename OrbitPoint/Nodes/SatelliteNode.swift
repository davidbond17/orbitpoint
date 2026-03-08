import SpriteKit

class SatelliteNode: SKNode {

    private let bodyNode: SKShapeNode
    private let glowNode: SKEffectNode
    private let glowShape: SKShapeNode
    private var trailNodes: [SKShapeNode] = []
    private let maxTrailNodes = 20

    var orbitCenter: CGPoint = .zero
    var orbitRadius: CGFloat = Theme.Dimensions.orbitRadius
    var angularVelocity: CGFloat = Theme.Animation.orbitSpeed
    var currentAngle: CGFloat = 0
    var isClockwise: Bool = true

    private var lastTrailTime: TimeInterval = 0
    private let trailInterval: TimeInterval = 0.03

    private var currentColor: SKColor = Theme.Colors.satelliteSK

    override init() {
        let color = StoreManager.shared.currentSatelliteColor
        currentColor = color

        bodyNode = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius)
        bodyNode.fillColor = color
        bodyNode.strokeColor = .clear
        bodyNode.zPosition = 20

        glowShape = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 2)
        glowShape.fillColor = color.withAlphaComponent(0.4)
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

    func refreshColors() {
        let color = StoreManager.shared.currentSatelliteColor
        currentColor = color
        bodyNode.fillColor = color
        glowShape.fillColor = color.withAlphaComponent(0.4)
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
        trail.fillColor = currentColor.withAlphaComponent(0.4)
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

    // MARK: - Power-Up Visuals

    private var shieldRing: SKShapeNode?
    private var savedTrailColor: SKColor?

    func showShieldEffect() {
        guard shieldRing == nil else { return }
        let ring = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius + 6)
        ring.fillColor = .clear
        ring.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
        ring.lineWidth = 2
        ring.glowWidth = 4
        ring.zPosition = 21
        ring.name = "shieldRing"
        addChild(ring)
        shieldRing = ring
    }

    func removeShieldEffect() {
        guard let ring = shieldRing else { return }
        let burst = SKAction.group([
            SKAction.scale(to: 3.0, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2)
        ])
        ring.run(SKAction.sequence([burst, SKAction.removeFromParent()]))
        shieldRing = nil
    }

    func showPhaseShift() {
        bodyNode.alpha = 0.3
        glowNode.alpha = 0.2
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.15, duration: 0.3),
            SKAction.fadeAlpha(to: 0.35, duration: 0.3)
        ])
        bodyNode.run(SKAction.repeatForever(shimmer), withKey: "phaseShimmer")
    }

    func removePhaseShift() {
        bodyNode.removeAction(forKey: "phaseShimmer")
        bodyNode.alpha = 1.0
        glowNode.alpha = 1.0
    }

    func showOrbitBoost() {
        savedTrailColor = currentColor
        let gold = SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        currentColor = gold
        bodyNode.fillColor = gold
        glowShape.fillColor = gold.withAlphaComponent(0.4)
    }

    func removeOrbitBoost() {
        if let saved = savedTrailColor {
            currentColor = saved
            bodyNode.fillColor = saved
            glowShape.fillColor = saved.withAlphaComponent(0.4)
            savedTrailColor = nil
        } else {
            refreshColors()
        }
    }
}
