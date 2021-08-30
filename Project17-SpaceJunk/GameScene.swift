//
//  GameScene.swift
//  Project17-SpaceJunk
//
//  Created by Felipe Gil on 2021-08-25.
//

import SpriteKit


class GameScene: SKScene {
    
    var starField : SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameTimer: Timer?
    var oldLocation: CGPoint?
    var isGameOver = false
    var enemyCounter = 0
    let possibleEnemies = ["ball", "hammer", "tv"]
    let customFont = "Chalkduster"
    let starFieldImage = "starfield"
    let playerImage = "player"
    let explosionEffect = "explosion"
    var interval: Double = 2.0 {
        didSet {
            self.gameTimerSet(interval: interval)
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let frameWidth = view.frame.width
        let frameHeight = view.frame.height
        backgroundColor = .black
        starField = SKEmitterNode(fileNamed: starFieldImage)
        starField.position = CGPoint(x: frameWidth, y: frameHeight / 2)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        player = SKSpriteNode(imageNamed: playerImage)
        player.position = CGPoint(x: frameWidth / 10, y: frameHeight / 2)
        if player.texture != nil {
            player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        }
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        scoreLabel = SKLabelNode(fontNamed: customFont)
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        interval = 1.0
    }
    
    private func gameTimerSet(interval: Double) {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc private func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        let sprite = SKSpriteNode(imageNamed: enemy)
        let frameWidth = Int(frame.width)
        let frameHeight = Int(frame.height)
        sprite.position = CGPoint (x: frameWidth, y: Int.random(in: 50...frameHeight))
        addChild(sprite)
        if sprite.texture != nil {
            sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        }
        
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        enemyCounter += 1
        
        if enemyCounter == 20 && interval > 0.2 {
            interval -= 0.1
            enemyCounter = 0
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -frame.width / 2  {
                node.removeFromParent()
            }
        }
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let oldLocation = oldLocation else { return }
        var location = touch.location(in: self)
        
        if player.contains(location) {
            if location.y < 100 {
                location.y = 100
            } else if location.y > 668 {
                location.y = 668
            }
                player.position = location
        } else {
            player.position = oldLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldLocation = player.position
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let explosion = SKEmitterNode(fileNamed: explosionEffect) else { return }
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        gameTimer?.invalidate()
        isGameOver = true
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
}
