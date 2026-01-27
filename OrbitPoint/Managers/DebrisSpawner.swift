import SpriteKit

class DebrisSpawner {

    private weak var scene: SKScene?
    private var debrisNodes: [DebrisNode] = []

    private var spawnTimer: TimeInterval = 0
    private var currentSpawnInterval: TimeInterval = 2.0

    private let initialSpawnInterval: TimeInterval = 2.0
    private let minimumSpawnInterval: TimeInterval = 0.4
    private let difficultyRampDuration: TimeInterval = 120.0

    private let debrisSpeed: ClosedRange<CGFloat> = 80...160
    private let safeZoneRadius: CGFloat = 150

    var gameTime: TimeInterval = 0

    init(scene: SKScene) {
        self.scene = scene
    }

    func reset() {
        for debris in debrisNodes {
            debris.removeFromParent()
        }
        debrisNodes.removeAll()
        spawnTimer = 0
        gameTime = 0
        currentSpawnInterval = initialSpawnInterval
    }

    func update(deltaTime: TimeInterval, starPosition: CGPoint) {
        gameTime += deltaTime
        spawnTimer += deltaTime

        updateDifficulty()

        if spawnTimer >= currentSpawnInterval {
            spawnDebris(avoidPosition: starPosition)
            spawnTimer = 0
        }

        updateDebris(deltaTime: deltaTime)
        removeOffscreenDebris()
    }

    private func updateDifficulty() {
        let progress = min(gameTime / difficultyRampDuration, 1.0)
        let easeProgress = 1 - pow(1 - progress, 2)
        currentSpawnInterval = initialSpawnInterval - (initialSpawnInterval - minimumSpawnInterval) * easeProgress
    }

    private func spawnDebris(avoidPosition: CGPoint) {
        guard let scene = scene else { return }

        let size = CGFloat.random(in: Theme.Dimensions.debrisMinSize...Theme.Dimensions.debrisMaxSize)
        let debris = DebrisNode(size: size)

        let edge = Int.random(in: 0...3)
        var spawnPosition: CGPoint
        var targetPosition: CGPoint

        let margin: CGFloat = 50

        switch edge {
        case 0: // Top
            spawnPosition = CGPoint(
                x: CGFloat.random(in: 0...scene.size.width),
                y: scene.size.height + margin
            )
        case 1: // Right
            spawnPosition = CGPoint(
                x: scene.size.width + margin,
                y: CGFloat.random(in: 0...scene.size.height)
            )
        case 2: // Bottom
            spawnPosition = CGPoint(
                x: CGFloat.random(in: 0...scene.size.width),
                y: -margin
            )
        default: // Left
            spawnPosition = CGPoint(
                x: -margin,
                y: CGFloat.random(in: 0...scene.size.height)
            )
        }

        let targetOffset = CGFloat.random(in: -safeZoneRadius...safeZoneRadius)
        targetPosition = CGPoint(
            x: avoidPosition.x + targetOffset,
            y: avoidPosition.y + targetOffset
        )

        let direction = CGVector(
            dx: targetPosition.x - spawnPosition.x,
            dy: targetPosition.y - spawnPosition.y
        )
        let length = hypot(direction.dx, direction.dy)
        let normalizedDirection = CGVector(
            dx: direction.dx / length,
            dy: direction.dy / length
        )

        let speed = CGFloat.random(in: debrisSpeed)
        debris.velocity = CGVector(
            dx: normalizedDirection.dx * speed,
            dy: normalizedDirection.dy * speed
        )

        debris.position = spawnPosition
        scene.addChild(debris)
        debrisNodes.append(debris)
    }

    private func updateDebris(deltaTime: TimeInterval) {
        for debris in debrisNodes {
            debris.update(deltaTime: deltaTime)
        }
    }

    private func removeOffscreenDebris() {
        guard let scene = scene else { return }

        let margin: CGFloat = 100
        let bounds = CGRect(
            x: -margin,
            y: -margin,
            width: scene.size.width + margin * 2,
            height: scene.size.height + margin * 2
        )

        debrisNodes.removeAll { debris in
            if !bounds.contains(debris.position) {
                debris.removeFromParent()
                return true
            }
            return false
        }
    }

    func checkCollisions(satellitePosition: CGPoint, satelliteRadius: CGFloat) -> Bool {
        for debris in debrisNodes {
            if debris.checkCollision(with: satellitePosition, satelliteRadius: satelliteRadius) {
                return true
            }
        }
        return false
    }
}
