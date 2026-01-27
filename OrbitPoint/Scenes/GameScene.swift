import SpriteKit

class GameScene: SKScene {

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = Theme.Colors.backgroundSK
        setupScene()
    }

    private func setupScene() {
        // Phase 2: Star, Satellite, and orbital mechanics will be added here
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Phase 2: Tap-to-reverse logic will be added here
    }

    override func update(_ currentTime: TimeInterval) {
        // Phase 2: Physics updates will be added here
    }
}
