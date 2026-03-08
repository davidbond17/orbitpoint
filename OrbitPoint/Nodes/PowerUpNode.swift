import SpriteKit

class PowerUpNode: SKNode {

    let type: PowerUpType
    private let bodyNode: SKShapeNode
    private let glowNode: SKEffectNode
    private let collectRadius: CGFloat = 20
    private(set) var isCollected = false
    private var lifetime: TimeInterval = 12.0
    private var elapsed: TimeInterval = 0
    var isExpired: Bool { elapsed >= lifetime }

    init(type: PowerUpType) {
        self.type = type

        let color = PowerUpNode.color(for: type)
        let path = PowerUpNode.shapePath(for: type)

        bodyNode = SKShapeNode(path: path)
        bodyNode.fillColor = color.withAlphaComponent(0.7)
        bodyNode.strokeColor = color
        bodyNode.lineWidth = 1.5
        bodyNode.zPosition = 15

        glowNode = SKEffectNode()
        let glowShape = SKShapeNode(path: path)
        glowShape.fillColor = color.withAlphaComponent(0.4)
        glowShape.strokeColor = .clear
        glowNode.addChild(glowShape)
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 6.0])
        glowNode.shouldRasterize = true
        glowNode.zPosition = 14

        super.init()

        addChild(glowNode)
        addChild(bodyNode)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        run(SKAction.repeatForever(pulse))

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4)
        bodyNode.run(SKAction.repeatForever(rotate))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        guard !isCollected && !isExpired else { return }
        elapsed += deltaTime

        if elapsed >= lifetime - 3.0 {
            if bodyNode.action(forKey: "blink") == nil {
                let blink = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.15),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.15)
                ])
                bodyNode.run(SKAction.repeatForever(blink), withKey: "blink")
                glowNode.run(SKAction.repeatForever(blink.copy() as! SKAction), withKey: "blink")
            }
        }

        if isExpired {
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            run(SKAction.sequence([fadeOut, SKAction.removeFromParent()]))
        }
    }

    func checkCollection(with satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        guard !isCollected && !isExpired else { return false }
        let distance = hypot(position.x - satellitePosition.x, position.y - satellitePosition.y)
        if distance < (collectRadius + satelliteRadius) {
            collect()
            return true
        }
        return false
    }

    private func collect() {
        isCollected = true
        removeAllActions()
        bodyNode.removeAllActions()
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        run(SKAction.sequence([SKAction.group([scaleUp, fadeOut]), SKAction.removeFromParent()]))
    }

    private static func color(for type: PowerUpType) -> SKColor {
        switch type {
        case .shield:
            return SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        case .slowField:
            return SKColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
        case .magnet:
            return SKColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1.0)
        case .phaseShift:
            return SKColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        case .orbitBoost:
            return SKColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0)
        }
    }

    private static func shapePath(for type: PowerUpType) -> CGPath {
        let path = CGMutablePath()
        switch type {
        case .shield:
            path.move(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: 8, y: 6))
            path.addLine(to: CGPoint(x: 8, y: -4))
            path.addLine(to: CGPoint(x: 0, y: -10))
            path.addLine(to: CGPoint(x: -8, y: -4))
            path.addLine(to: CGPoint(x: -8, y: 6))
            path.closeSubpath()
        case .slowField:
            path.addEllipse(in: CGRect(x: -8, y: -8, width: 16, height: 16))
        case .magnet:
            path.move(to: CGPoint(x: -7, y: 8))
            path.addLine(to: CGPoint(x: -7, y: -2))
            path.addQuadCurve(to: CGPoint(x: 7, y: -2), control: CGPoint(x: 0, y: -12))
            path.addLine(to: CGPoint(x: 7, y: 8))
            path.addLine(to: CGPoint(x: 4, y: 8))
            path.addLine(to: CGPoint(x: 4, y: -1))
            path.addQuadCurve(to: CGPoint(x: -4, y: -1), control: CGPoint(x: 0, y: -8))
            path.addLine(to: CGPoint(x: -4, y: 8))
            path.closeSubpath()
        case .phaseShift:
            path.move(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: 7, y: 3))
            path.addLine(to: CGPoint(x: 3, y: 3))
            path.addLine(to: CGPoint(x: 3, y: -3))
            path.addLine(to: CGPoint(x: 7, y: -3))
            path.addLine(to: CGPoint(x: 0, y: -10))
            path.addLine(to: CGPoint(x: -7, y: -3))
            path.addLine(to: CGPoint(x: -3, y: -3))
            path.addLine(to: CGPoint(x: -3, y: 3))
            path.addLine(to: CGPoint(x: -7, y: 3))
            path.closeSubpath()
        case .orbitBoost:
            path.move(to: CGPoint(x: 2, y: 10))
            path.addLine(to: CGPoint(x: -4, y: 2))
            path.addLine(to: CGPoint(x: 0, y: 2))
            path.addLine(to: CGPoint(x: -2, y: -10))
            path.addLine(to: CGPoint(x: 4, y: -2))
            path.addLine(to: CGPoint(x: 0, y: -2))
            path.closeSubpath()
        }
        return path
    }
}
