import SpriteKit

class StarfieldNode: SKNode {

    private var twinklingStars: [SKSpriteNode] = []
    private let totalStarCount = 50
    private let twinklingStarCount = 15
    private var sceneSize: CGSize = .zero

    private static var starTexture: SKTexture?

    init(size: CGSize) {
        self.sceneSize = size
        super.init()
        zPosition = -10
        createStarfield()
        startTwinkling()
        scheduleShootingStars()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func getStarTexture() -> SKTexture {
        if let existing = starTexture {
            return existing
        }
        let shape = SKShapeNode(circleOfRadius: 4)
        shape.fillColor = .white
        shape.strokeColor = .clear
        let texture = SKView().texture(from: shape) ?? SKTexture()
        starTexture = texture
        return texture
    }

    private func createStarfield() {
        let texture = StarfieldNode.getStarTexture()

        for i in 0..<totalStarCount {
            let layer = Int.random(in: 0...2)
            let baseSize: CGFloat
            let baseAlpha: CGFloat

            switch layer {
            case 0:
                baseSize = CGFloat.random(in: 1.0...2.0)
                baseAlpha = CGFloat.random(in: 0.2...0.4)
            case 1:
                baseSize = CGFloat.random(in: 2.0...3.0)
                baseAlpha = CGFloat.random(in: 0.4...0.6)
            default:
                baseSize = CGFloat.random(in: 3.0...5.0)
                baseAlpha = CGFloat.random(in: 0.6...0.9)
            }

            let star = SKSpriteNode(texture: texture)
            star.size = CGSize(width: baseSize, height: baseSize)
            star.alpha = baseAlpha
            star.color = starColor()
            star.colorBlendFactor = 1.0
            star.position = CGPoint(
                x: CGFloat.random(in: 0...sceneSize.width),
                y: CGFloat.random(in: 0...sceneSize.height)
            )
            star.zPosition = CGFloat(-layer)

            addChild(star)

            if i < twinklingStarCount {
                twinklingStars.append(star)
            }
        }

        createNebulaGlow()
    }

    private func starColor() -> SKColor {
        let colors: [SKColor] = [
            SKColor(white: 1.0, alpha: 1.0),
            SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0),
            SKColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0),
            SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
        ]
        return colors.randomElement() ?? .white
    }

    private func createNebulaGlow() {
        let nebulaColors: [SKColor] = [
            SKColor(red: 0.3, green: 0.2, blue: 0.5, alpha: 0.06),
            SKColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 0.05),
            SKColor(red: 0.4, green: 0.2, blue: 0.4, alpha: 0.04)
        ]

        for color in nebulaColors {
            let nebula = SKShapeNode(circleOfRadius: CGFloat.random(in: 80...140))
            nebula.fillColor = color
            nebula.strokeColor = .clear
            nebula.position = CGPoint(
                x: CGFloat.random(in: 0...sceneSize.width),
                y: CGFloat.random(in: 0...sceneSize.height)
            )
            nebula.zPosition = -20
            nebula.blendMode = .add
            addChild(nebula)
        }
    }

    private func startTwinkling() {
        for star in twinklingStars {
            let delay = Double.random(in: 0...4)
            let twinkleDuration = Double.random(in: 2.0...4.0)

            let originalAlpha = star.alpha
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: originalAlpha * 0.3, duration: twinkleDuration / 2),
                SKAction.fadeAlpha(to: originalAlpha, duration: twinkleDuration / 2)
            ])

            let delayAction = SKAction.wait(forDuration: delay)
            let twinkleForever = SKAction.repeatForever(twinkle)

            star.run(SKAction.sequence([delayAction, twinkleForever]))
        }
    }

    private func scheduleShootingStars() {
        let spawnShootingStar = SKAction.run { [weak self] in
            self?.createShootingStar()
        }

        let wait = SKAction.wait(forDuration: 10, withRange: 8)
        let sequence = SKAction.sequence([wait, spawnShootingStar])
        run(SKAction.repeatForever(sequence))
    }

    private func createShootingStar() {
        let startX = CGFloat.random(in: sceneSize.width * 0.3...sceneSize.width)
        let startY = CGFloat.random(in: sceneSize.height * 0.5...sceneSize.height)

        let shootingStar = SKSpriteNode(texture: StarfieldNode.getStarTexture())
        shootingStar.size = CGSize(width: 4, height: 4)
        shootingStar.position = CGPoint(x: startX, y: startY)
        shootingStar.zPosition = -5
        shootingStar.alpha = 0

        addChild(shootingStar)

        let endX = startX - 200
        let endY = startY - 100

        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: 0.5)
        move.timingMode = .easeIn
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()

        shootingStar.run(SKAction.sequence([fadeIn, move, fadeOut, remove]))
    }
}
