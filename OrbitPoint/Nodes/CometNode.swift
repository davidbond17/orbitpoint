import SpriteKit

class CometNode: SKNode {

    private let bodyNode: SKShapeNode
    private let trailEmitter: SKEmitterNode
    let collisionRadius: CGFloat = 10

    var velocity: CGVector = .zero

    override init() {
        let cometColor = SKColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)

        bodyNode = SKShapeNode(circleOfRadius: 6)
        bodyNode.fillColor = cometColor
        bodyNode.strokeColor = SKColor.white
        bodyNode.lineWidth = 1
        bodyNode.zPosition = 16
        bodyNode.glowWidth = 3

        trailEmitter = SKEmitterNode()
        trailEmitter.particleBirthRate = 60
        trailEmitter.particleLifetime = 0.6
        trailEmitter.particleLifetimeRange = 0.2
        trailEmitter.particleAlpha = 0.7
        trailEmitter.particleAlphaSpeed = -1.2
        trailEmitter.particleScale = 0.3
        trailEmitter.particleScaleSpeed = -0.3
        trailEmitter.particleColor = cometColor
        trailEmitter.particleColorBlendFactor = 1.0
        trailEmitter.particleSpeed = 0
        trailEmitter.emissionAngle = 0
        trailEmitter.emissionAngleRange = .pi * 2
        trailEmitter.zPosition = 14

        let texture = SKShapeNode(circleOfRadius: 4)
        texture.fillColor = .white
        texture.strokeColor = .clear
        let textureView = SKView()
        trailEmitter.particleTexture = textureView.texture(from: texture)

        super.init()

        addChild(trailEmitter)
        addChild(bodyNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        position.x += velocity.dx * CGFloat(deltaTime)
        position.y += velocity.dy * CGFloat(deltaTime)
    }

    func checkCollision(with satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        let distance = hypot(position.x - satellitePosition.x, position.y - satellitePosition.y)
        return distance < (collisionRadius + satelliteRadius)
    }
}
