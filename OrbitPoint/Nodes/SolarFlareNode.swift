import SpriteKit

class SolarFlareNode: SKNode {

    private let arcNode: SKShapeNode
    private let warningNode: SKShapeNode
    let arcStartAngle: CGFloat
    let arcSpan: CGFloat
    let radius: CGFloat
    let center: CGPoint

    private var warningTime: TimeInterval = 1.5
    private var activeTime: TimeInterval = 1.0
    private var elapsed: TimeInterval = 0
    private(set) var isActive = false
    private(set) var isFinished = false

    init(center: CGPoint, radius: CGFloat, arcStartAngle: CGFloat, arcSpan: CGFloat) {
        self.center = center
        self.radius = radius
        self.arcStartAngle = arcStartAngle
        self.arcSpan = arcSpan

        let flareColor = SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0)

        let warningPath = CGMutablePath()
        warningPath.addArc(center: .zero, radius: radius, startAngle: arcStartAngle, endAngle: arcStartAngle + arcSpan, clockwise: false)
        warningNode = SKShapeNode(path: warningPath)
        warningNode.strokeColor = flareColor.withAlphaComponent(0.3)
        warningNode.lineWidth = 20
        warningNode.lineCap = .round
        warningNode.zPosition = 12

        let flarePath = CGMutablePath()
        flarePath.addArc(center: .zero, radius: radius, startAngle: arcStartAngle, endAngle: arcStartAngle + arcSpan, clockwise: false)
        arcNode = SKShapeNode(path: flarePath)
        arcNode.strokeColor = flareColor
        arcNode.lineWidth = 30
        arcNode.lineCap = .round
        arcNode.zPosition = 13
        arcNode.alpha = 0

        super.init()

        position = center
        addChild(warningNode)
        addChild(arcNode)

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.2),
            SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        ])
        warningNode.run(SKAction.repeatForever(pulse))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        guard !isFinished else { return }
        elapsed += deltaTime

        if elapsed >= warningTime && !isActive {
            isActive = true
            warningNode.removeAllActions()
            warningNode.alpha = 0
            arcNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.1))
        }

        if elapsed >= warningTime + activeTime {
            isFinished = true
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            arcNode.run(SKAction.sequence([fadeOut, SKAction.removeFromParent()]))
            warningNode.run(SKAction.sequence([fadeOut, SKAction.removeFromParent()]))
            run(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.removeFromParent()]))
        }
    }

    func checkCollision(with satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        guard isActive && !isFinished else { return false }

        let dx = satellitePosition.x - center.x
        let dy = satellitePosition.y - center.y
        let distance = hypot(dx, dy)

        guard abs(distance - radius) < (15 + satelliteRadius) else { return false }

        var angle = atan2(dy, dx)
        if angle < 0 { angle += .pi * 2 }

        var start = arcStartAngle
        if start < 0 { start += .pi * 2 }
        let end = start + arcSpan

        if end > .pi * 2 {
            return angle >= start || angle <= (end - .pi * 2)
        }
        return angle >= start && angle <= end
    }
}
