import SpriteKit

class DebrisSpawner {

    private weak var scene: SKScene?
    private var debrisNodes: [DebrisNode] = []
    private var cometNodes: [CometNode] = []
    private var solarFlareNodes: [SolarFlareNode] = []
    private var gravityWellNodes: [GravityWellNode] = []

    private var spawnTimer: TimeInterval = 0
    private var currentSpawnInterval: TimeInterval = 2.0

    private var initialSpawnInterval: TimeInterval = 2.0
    private var minimumSpawnInterval: TimeInterval = 0.4
    private var difficultyRampDuration: TimeInterval = 120.0

    private var debrisSpeed: ClosedRange<CGFloat> = 80...160
    private var safeZoneRadius: CGFloat = 150

    private var hazardConfig = HazardConfig()
    private var cometTimer: TimeInterval = 0
    private var solarFlareTimer: TimeInterval = 0
    private var gravityWellTimer: TimeInterval = 0

    var gameTime: TimeInterval = 0
    var debrisSpeedMultiplier: CGFloat = 1.0
    var orbitRadii: [CGFloat]?

    init(scene: SKScene) {
        self.scene = scene
    }

    func configure(with config: DebrisConfig) {
        initialSpawnInterval = config.initialSpawnInterval
        minimumSpawnInterval = config.minimumSpawnInterval
        difficultyRampDuration = config.difficultyRampDuration
        debrisSpeed = config.debrisSpeedRange
        safeZoneRadius = config.safeZoneRadius
        currentSpawnInterval = initialSpawnInterval
        hazardConfig = config.hazards
    }

    func reset() {
        for debris in debrisNodes { debris.removeFromParent() }
        for comet in cometNodes { comet.removeFromParent() }
        for flare in solarFlareNodes { flare.removeFromParent() }
        for well in gravityWellNodes { well.removeFromParent() }
        debrisNodes.removeAll()
        cometNodes.removeAll()
        solarFlareNodes.removeAll()
        gravityWellNodes.removeAll()
        spawnTimer = 0
        cometTimer = 0
        solarFlareTimer = 0
        gravityWellTimer = 0
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

        updateHazards(deltaTime: deltaTime, starPosition: starPosition)
        updateDebris(deltaTime: deltaTime)
        applyGravityWellsToDebris(deltaTime: deltaTime)
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
        let adjustedDelta = deltaTime * Double(debrisSpeedMultiplier)
        for debris in debrisNodes {
            debris.update(deltaTime: adjustedDelta)
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
        for comet in cometNodes {
            if comet.checkCollision(with: satellitePosition, satelliteRadius: satelliteRadius) {
                return true
            }
        }
        for flare in solarFlareNodes {
            if flare.checkCollision(with: satellitePosition, satelliteRadius: satelliteRadius) {
                return true
            }
        }
        for well in gravityWellNodes {
            if well.checkCollision(with: satellitePosition, satelliteRadius: satelliteRadius) {
                return true
            }
        }
        return false
    }

    // MARK: - Hazard Management

    private func updateHazards(deltaTime: TimeInterval, starPosition: CGPoint) {
        let adjustedDelta = deltaTime * Double(debrisSpeedMultiplier)

        if hazardConfig.cometsEnabled {
            cometTimer += deltaTime
            if cometTimer >= hazardConfig.cometInterval {
                spawnComet(avoidPosition: starPosition)
                cometTimer = 0
            }
            for comet in cometNodes {
                comet.update(deltaTime: adjustedDelta)
            }
            removeOffscreenComets()
        }

        if hazardConfig.solarFlaresEnabled {
            solarFlareTimer += deltaTime
            if solarFlareTimer >= hazardConfig.solarFlareInterval {
                spawnSolarFlare(starPosition: starPosition)
                solarFlareTimer = 0
            }
            for flare in solarFlareNodes {
                flare.update(deltaTime: adjustedDelta)
            }
            solarFlareNodes.removeAll { $0.isFinished }
        }

        if hazardConfig.gravityWellsEnabled {
            gravityWellTimer += deltaTime
            if gravityWellTimer >= hazardConfig.gravityWellInterval {
                spawnGravityWell(starPosition: starPosition)
                gravityWellTimer = 0
            }
            for well in gravityWellNodes {
                well.update(deltaTime: adjustedDelta)
            }
            gravityWellNodes.removeAll { $0.isFinished }
        }
    }

    private func spawnComet(avoidPosition: CGPoint) {
        guard let scene = scene else { return }

        let comet = CometNode()
        let edge = Int.random(in: 0...3)
        let margin: CGFloat = 50

        var spawnPosition: CGPoint
        switch edge {
        case 0:
            spawnPosition = CGPoint(x: CGFloat.random(in: 0...scene.size.width), y: scene.size.height + margin)
        case 1:
            spawnPosition = CGPoint(x: scene.size.width + margin, y: CGFloat.random(in: 0...scene.size.height))
        case 2:
            spawnPosition = CGPoint(x: CGFloat.random(in: 0...scene.size.width), y: -margin)
        default:
            spawnPosition = CGPoint(x: -margin, y: CGFloat.random(in: 0...scene.size.height))
        }

        let targetOffset = CGFloat.random(in: -safeZoneRadius * 0.5...safeZoneRadius * 0.5)
        let targetPosition = CGPoint(x: avoidPosition.x + targetOffset, y: avoidPosition.y + targetOffset)

        let dx = targetPosition.x - spawnPosition.x
        let dy = targetPosition.y - spawnPosition.y
        let length = hypot(dx, dy)

        let baseSpeed = CGFloat.random(in: debrisSpeed) * hazardConfig.cometSpeedMultiplier
        comet.velocity = CGVector(dx: dx / length * baseSpeed, dy: dy / length * baseSpeed)
        comet.position = spawnPosition

        scene.addChild(comet)
        cometNodes.append(comet)
    }

    private func removeOffscreenComets() {
        guard let scene = scene else { return }
        let margin: CGFloat = 100
        let bounds = CGRect(x: -margin, y: -margin, width: scene.size.width + margin * 2, height: scene.size.height + margin * 2)
        cometNodes.removeAll { comet in
            if !bounds.contains(comet.position) {
                comet.removeFromParent()
                return true
            }
            return false
        }
    }

    private func spawnSolarFlare(starPosition: CGPoint) {
        guard let scene = scene else { return }
        let startAngle = CGFloat.random(in: 0...(CGFloat.pi * 2))
        let span = CGFloat.random(in: (.pi / 4)...(.pi / 2))

        let targetRadii: [CGFloat]
        if let radii = orbitRadii {
            targetRadii = radii
        } else {
            targetRadii = [Theme.Dimensions.orbitRadius]
        }

        let flareRadius = targetRadii.randomElement()!
        let flare = SolarFlareNode(
            center: starPosition,
            radius: flareRadius,
            arcStartAngle: startAngle,
            arcSpan: span
        )
        scene.addChild(flare)
        solarFlareNodes.append(flare)
    }

    private func spawnGravityWell(starPosition: CGPoint) {
        guard let scene = scene else { return }
        let well = GravityWellNode()
        let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
        let distance = Theme.Dimensions.orbitRadius + CGFloat.random(in: -40...60)
        well.position = CGPoint(
            x: starPosition.x + cos(angle) * distance,
            y: starPosition.y + sin(angle) * distance
        )
        scene.addChild(well)
        gravityWellNodes.append(well)
    }

    private func applyGravityWellsToDebris(deltaTime: TimeInterval) {
        for well in gravityWellNodes where !well.isFinished {
            for debris in debrisNodes {
                let force = well.pullForce(on: debris.position)
                debris.velocity.dx += force.dx * CGFloat(deltaTime)
                debris.velocity.dy += force.dy * CGFloat(deltaTime)
            }
            for comet in cometNodes {
                let force = well.pullForce(on: comet.position)
                comet.velocity.dx += force.dx * CGFloat(deltaTime)
                comet.velocity.dy += force.dy * CGFloat(deltaTime)
            }
        }
    }
}
