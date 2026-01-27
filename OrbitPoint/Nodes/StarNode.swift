import SpriteKit

class StarNode: SKNode {

    private let coreNode: SKShapeNode
    private let glowNode: SKEffectNode
    private let pulseAction: SKAction

    override init() {
        coreNode = SKShapeNode(circleOfRadius: Theme.Dimensions.starRadius)
        coreNode.fillColor = Theme.Colors.starCoreSK
        coreNode.strokeColor = .clear
        coreNode.zPosition = 10

        let glowShape = SKShapeNode(circleOfRadius: Theme.Dimensions.starRadius * 2.5)
        glowShape.fillColor = Theme.Colors.starGlowSK
        glowShape.strokeColor = .clear

        glowNode = SKEffectNode()
        glowNode.shouldRasterize = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 30])
        glowNode.addChild(glowShape)
        glowNode.zPosition = 5

        let scaleUp = SKAction.scale(to: 1.15, duration: Theme.Animation.glowPulseSpeed)
        let scaleDown = SKAction.scale(to: 0.95, duration: Theme.Animation.glowPulseSpeed)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        pulseAction = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))

        super.init()

        addChild(glowNode)
        addChild(coreNode)

        glowNode.run(pulseAction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
