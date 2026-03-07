import SpriteKit

class LoreFragmentNode: SKNode {

    let fragmentId: String
    private let bodyNode: SKShapeNode
    private let glowNode: SKEffectNode
    private let glowShape: SKShapeNode
    private let collectRadius: CGFloat = 20

    var isCollected = false

    init(fragmentId: String) {
        self.fragmentId = fragmentId

        let crystalColor = SKColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0)

        let diamondPath = CGMutablePath()
        diamondPath.move(to: CGPoint(x: 0, y: 8))
        diamondPath.addLine(to: CGPoint(x: 6, y: 0))
        diamondPath.addLine(to: CGPoint(x: 0, y: -8))
        diamondPath.addLine(to: CGPoint(x: -6, y: 0))
        diamondPath.closeSubpath()

        bodyNode = SKShapeNode(path: diamondPath)
        bodyNode.fillColor = crystalColor
        bodyNode.strokeColor = SKColor.white.withAlphaComponent(0.8)
        bodyNode.lineWidth = 1
        bodyNode.zPosition = 25

        glowShape = SKShapeNode(circleOfRadius: 12)
        glowShape.fillColor = crystalColor.withAlphaComponent(0.3)
        glowShape.strokeColor = .clear

        glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 6])
        glowNode.addChild(glowShape)
        glowNode.zPosition = 24

        super.init()

        addChild(glowNode)
        addChild(bodyNode)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.8),
            SKAction.scale(to: 1.0, duration: 0.8)
        ])
        bodyNode.run(SKAction.repeatForever(pulse))

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4)
        bodyNode.run(SKAction.repeatForever(rotate))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func checkCollection(with satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        guard !isCollected else { return false }
        let distance = hypot(position.x - satellitePosition.x, position.y - satellitePosition.y)
        if distance < (collectRadius + satelliteRadius) {
            collect()
            return true
        }
        return false
    }

    private func collect() {
        isCollected = true

        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleUp, fadeOut])
        let remove = SKAction.removeFromParent()

        run(SKAction.sequence([group, remove]))
    }
}
