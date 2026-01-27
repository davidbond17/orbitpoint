import SpriteKit

class DebrisNode: SKNode {

    static let categoryBitMask: UInt32 = 0x1 << 1

    private let bodyNode: SKShapeNode
    private let size: CGFloat

    var velocity: CGVector = .zero

    init(size: CGFloat) {
        self.size = size

        let points = DebrisNode.generateIrregularShape(size: size)
        let path = CGMutablePath()
        path.addLines(between: points)
        path.closeSubpath()

        bodyNode = SKShapeNode(path: path)
        bodyNode.fillColor = Theme.Colors.debrisSK
        bodyNode.strokeColor = Theme.Colors.debrisSK.withAlphaComponent(0.8)
        bodyNode.lineWidth = 1
        bodyNode.zPosition = 15

        super.init()

        addChild(bodyNode)

        let rotationSpeed = CGFloat.random(in: -2...2)
        let rotateAction = SKAction.rotate(byAngle: .pi * 2 * (rotationSpeed > 0 ? 1 : -1), duration: abs(3 / Double(rotationSpeed)))
        bodyNode.run(SKAction.repeatForever(rotateAction))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func generateIrregularShape(size: CGFloat) -> [CGPoint] {
        let pointCount = Int.random(in: 5...7)
        var points: [CGPoint] = []

        for i in 0..<pointCount {
            let angle = (CGFloat(i) / CGFloat(pointCount)) * .pi * 2
            let radius = size * CGFloat.random(in: 0.6...1.0)
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            points.append(CGPoint(x: x, y: y))
        }

        return points
    }

    func update(deltaTime: TimeInterval) {
        position.x += velocity.dx * CGFloat(deltaTime)
        position.y += velocity.dy * CGFloat(deltaTime)
    }

    func checkCollision(with satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        let distance = hypot(position.x - satellitePosition.x, position.y - satellitePosition.y)
        return distance < (size + satelliteRadius)
    }
}
