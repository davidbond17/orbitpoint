import SpriteKit

class GravityWellNode: SKNode {

    private let bodyNode: SKShapeNode
    private let pulseRing: SKShapeNode
    let collisionRadius: CGFloat = 18
    let pullRadius: CGFloat = 120
    let pullStrength: CGFloat = 40

    private var lifetime: TimeInterval = 6.0
    private var elapsed: TimeInterval = 0
    private(set) var isFinished = false

    override init() {
        let wellColor = SKColor(red: 0.5, green: 0.0, blue: 0.8, alpha: 1.0)

        bodyNode = SKShapeNode(circleOfRadius: 12)
        bodyNode.fillColor = wellColor.withAlphaComponent(0.6)
        bodyNode.strokeColor = wellColor
        bodyNode.lineWidth = 2
        bodyNode.zPosition = 14
        bodyNode.glowWidth = 5

        pulseRing = SKShapeNode(circleOfRadius: 20)
        pulseRing.fillColor = .clear
        pulseRing.strokeColor = wellColor.withAlphaComponent(0.3)
        pulseRing.lineWidth = 1
        pulseRing.zPosition = 13

        super.init()

        addChild(pulseRing)
        addChild(bodyNode)

        let expand = SKAction.scale(to: 4.0, duration: 1.5)
        let fade = SKAction.fadeAlpha(to: 0, duration: 1.5)
        let reset = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0),
            SKAction.fadeAlpha(to: 0.3, duration: 0)
        ])
        pulseRing.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([expand, fade]),
            reset
        ])))

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3)
        bodyNode.run(SKAction.repeatForever(rotate))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        guard !isFinished else { return }
        elapsed += deltaTime

        if elapsed >= lifetime - 1.0 {
            let blink = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.1),
                SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            ])
            if bodyNode.action(forKey: "blink") == nil {
                bodyNode.run(SKAction.repeatForever(blink), withKey: "blink")
            }
        }

        if elapsed >= lifetime {
            isFinished = true
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            run(SKAction.sequence([fadeOut, SKAction.removeFromParent()]))
        }
    }

    func pullForce(on targetPosition: CGPoint) -> CGVector {
        guard !isFinished else { return .zero }
        let dx = position.x - targetPosition.x
        let dy = position.y - targetPosition.y
        let distance = hypot(dx, dy)

        guard distance < pullRadius && distance > 5 else { return .zero }

        let strength = pullStrength * (1.0 - distance / pullRadius)
        let normalizedDx = dx / distance
        let normalizedDy = dy / distance

        return CGVector(dx: normalizedDx * strength, dy: normalizedDy * strength)
    }

    func checkCollision(with satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        let distance = hypot(position.x - satellitePosition.x, position.y - satellitePosition.y)
        return distance < (collisionRadius + satelliteRadius)
    }
}
