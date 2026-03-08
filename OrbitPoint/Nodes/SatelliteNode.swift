import SpriteKit

class SatelliteNode: SKNode {

    private let bodyNode: SKShapeNode
    private let glowNode: SKEffectNode
    private let glowShape: SKShapeNode
    private var trailNodes: [SKShapeNode] = []
    private let maxTrailNodes = 20

    var orbitCenter: CGPoint = .zero
    var orbitRadius: CGFloat = Theme.Dimensions.orbitRadius
    var targetOrbitRadius: CGFloat = Theme.Dimensions.orbitRadius
    var angularVelocity: CGFloat = Theme.Animation.orbitSpeed
    var currentAngle: CGFloat = 0
    var isClockwise: Bool = true
    private(set) var isTransitioning: Bool = false

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

    func switchToOrbit(radius: CGFloat) {
        guard radius != targetOrbitRadius else { return }
        targetOrbitRadius = radius
        isTransitioning = true
    }

    func updateOrbit(deltaTime: TimeInterval, currentTime: TimeInterval) {
        if isTransitioning {
            let speed: CGFloat = 300
            let diff = targetOrbitRadius - orbitRadius
            let step = speed * CGFloat(deltaTime)
            if abs(diff) <= step {
                orbitRadius = targetOrbitRadius
                isTransitioning = false
            } else {
                orbitRadius += (diff > 0 ? step : -step)
            }
        }

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

        let style = StoreManager.shared.currentTrailStyle
        let trail: SKShapeNode
        var fadeDuration = Theme.Animation.trailFadeDuration
        var startAlpha: CGFloat = 0.6

        switch style {
        case .classic:
            trail = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 0.6)
            trail.fillColor = currentColor.withAlphaComponent(0.4)

        case .dotted:
            trail = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 0.3)
            trail.fillColor = currentColor.withAlphaComponent(0.6)
            fadeDuration = 0.3

        case .dashed:
            let size = CGSize(width: Theme.Dimensions.satelliteRadius * 1.2, height: Theme.Dimensions.satelliteRadius * 0.4)
            trail = SKShapeNode(rectOf: size, cornerRadius: 2)
            trail.fillColor = currentColor.withAlphaComponent(0.5)
            trail.zRotation = currentAngle
            fadeDuration = 0.5

        case .sparkle:
            trail = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 0.4)
            trail.fillColor = currentColor.withAlphaComponent(0.7)
            startAlpha = 0.8
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: fadeDuration)
            trail.run(rotate)

        case .rainbow:
            trail = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 0.6)
            let hue = CGFloat(fmod(Double(currentAngle) / (.pi * 2), 1.0))
            trail.fillColor = SKColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.5)

        case .fire:
            trail = SKShapeNode(circleOfRadius: Theme.Dimensions.satelliteRadius * 0.5)
            let mix = CGFloat.random(in: 0...1)
            let r: CGFloat = 1.0
            let g: CGFloat = 0.2 + mix * 0.4
            let b: CGFloat = 0.05
            trail.fillColor = SKColor(red: r, green: g, blue: b, alpha: 0.6)
            startAlpha = 0.7
            fadeDuration = 0.4
        }

        trail.strokeColor = .clear
        trail.position = position
        trail.zPosition = 5
        trail.alpha = startAlpha

        parentNode.addChild(trail)
        trailNodes.append(trail)

        let fadeOut = SKAction.fadeOut(withDuration: fadeDuration)
        let scaleDown = SKAction.scale(to: 0.3, duration: fadeDuration)
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
