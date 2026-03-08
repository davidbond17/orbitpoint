import SpriteKit

class PowerUpManager {

    private weak var scene: SKScene?
    private var config = PowerUpConfig()
    private var spawnTimer: TimeInterval = 0
    private var powerUpNode: PowerUpNode?

    private(set) var activePowerUp: PowerUpType?
    private(set) var activeTimeRemaining: TimeInterval = 0

    init(scene: SKScene) {
        self.scene = scene
    }

    func configure(with config: PowerUpConfig) {
        self.config = config
    }

    func reset() {
        powerUpNode?.removeFromParent()
        powerUpNode = nil
        spawnTimer = 0
        activePowerUp = nil
        activeTimeRemaining = 0
    }

    func update(deltaTime: TimeInterval, center: CGPoint, orbitRadius: CGFloat) {
        guard config.enabled else { return }

        if let node = powerUpNode {
            node.update(deltaTime: deltaTime)
            if node.isExpired {
                powerUpNode = nil
            }
        }

        if powerUpNode == nil && activePowerUp == nil {
            spawnTimer += deltaTime
            if spawnTimer >= config.spawnInterval {
                spawnPowerUp(center: center, orbitRadius: orbitRadius)
                spawnTimer = 0
            }
        }

        if let type = activePowerUp, type != .shield {
            activeTimeRemaining -= deltaTime
            if activeTimeRemaining <= 0 {
                activeTimeRemaining = 0
                activePowerUp = nil
            }
        }
    }

    func checkCollection(satellitePosition: CGPoint, satelliteRadius: CGFloat) -> PowerUpType? {
        guard let node = powerUpNode, !node.isCollected else { return nil }
        let collectRadius = isActive(.magnet) ? satelliteRadius * 3 : satelliteRadius
        if node.checkCollection(with: satellitePosition, satelliteRadius: collectRadius) {
            let type = node.type
            powerUpNode = nil
            return type
        }
        return nil
    }

    func activate(_ type: PowerUpType) {
        activePowerUp = type
        activeTimeRemaining = type.duration
        spawnTimer = 0
    }

    func consumeShield() {
        guard activePowerUp == .shield else { return }
        activePowerUp = nil
        activeTimeRemaining = 0
    }

    func isActive(_ type: PowerUpType) -> Bool {
        activePowerUp == type
    }

    var isShieldActive: Bool { activePowerUp == .shield }
    var isPhaseShiftActive: Bool { activePowerUp == .phaseShift }

    var debrisSpeedMultiplier: CGFloat {
        activePowerUp == .slowField ? 0.5 : 1.0
    }

    var scoreMultiplier: Int {
        activePowerUp == .orbitBoost ? 2 : 1
    }

    var effectiveCollectRadius: CGFloat {
        activePowerUp == .magnet ? Theme.Dimensions.satelliteRadius * 3 : Theme.Dimensions.satelliteRadius
    }

    private func spawnPowerUp(center: CGPoint, orbitRadius: CGFloat) {
        guard let scene = scene, !config.availableTypes.isEmpty else { return }

        let type = config.availableTypes.randomElement()!
        let node = PowerUpNode(type: type)
        let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
        node.position = CGPoint(
            x: center.x + cos(angle) * orbitRadius,
            y: center.y + sin(angle) * orbitRadius
        )
        scene.addChild(node)
        powerUpNode = node
    }
}
