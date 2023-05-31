//
//  GameScene.swift
//  SpaceWar
//
//  Created by m223 on 30.05.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceShipCategory: UInt32 = 0x1 << 0
    let asteroidCategory: UInt32 = 0x1 << 1
    
    
    var spaceShip: SKSpriteNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var backgroundSpace: SKSpriteNode!
    var asteroidLayer: SKNode!
    
    
    var gameIsPaused: Bool = false
    
//    func pauseTheGame() {
//
//        gameIsPaused = true
//        self.asteroidLayer.isPaused = true
//        physicsWorld.speed = 0
//    }
//
//    func unPauseTheGame() {
//        gameIsPaused = false
//        self.asteroidLayer.isPaused = false
//        physicsWorld.speed = 1
//
//    }
//
//    func resetTheGame() {
//        score = 0
//        scoreLabel.text = "Score: \(score)"
//
//        gameIsPaused = false
//        self.asteroidLayer.isPaused = false
//        physicsWorld.speed = 1
//
//    }

    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        
        scene?.size = UIScreen.main.bounds.size
        
        backgroundSpace = SKSpriteNode(imageNamed: "space")
        backgroundSpace.zPosition = 0.9
        backgroundSpace.size = CGSize(width: UIScreen.main.bounds.width + 50, height: UIScreen.main.bounds.height + 50)
        addChild(backgroundSpace)

        spaceShip = SKSpriteNode(imageNamed: "plane")
        spaceShip.xScale = 1.5
        spaceShip.yScale = 1.5
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        spaceShip.blendMode = .add
        spaceShip.zPosition = 1

        addChild(spaceShip)
        
        let colorAction1 = SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 1)
        let colorAction2 = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 1)
        
        let colorSequenceAnimation = SKAction.sequence([colorAction1, colorAction2])
        let colorActionRepeat = SKAction.repeatForever(colorSequenceAnimation)
        
        spaceShip.run(colorActionRepeat)
        
        
        //generation asteroid
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 1
        addChild(asteroidLayer)
        
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            self.asteroidLayer.addChild(asteroid)
            asteroid.zPosition = 1
        }
        
        
        let asteroidPerSecond: Double = 10.0
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / asteroidPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        
        
        self.asteroidLayer.run(asteroidRunAction)
        
        scoreLabel = SKLabelNode(text: "Score \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / scoreLabel.frame.size.width, y: 300)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            print(touchLocation)
            
            let distance = distanceCalc(a: spaceShip.position, b: touchLocation)
            let speed: CGFloat = 500
            let time = timeToIntervalDistance(distance: distance, speed: speed)
            let moveAction = SKAction.move(to: touchLocation, duration: time)
            moveAction.timingMode = SKActionTimingMode.easeInEaseOut

            
            spaceShip.run(moveAction)
            
            let bgMoveaction = SKAction.move(to: CGPoint(x: -touchLocation.x / 100, y: -touchLocation.y / 100), duration: time)
            
            backgroundSpace.run(bgMoveaction)
            
            //self.asteroidLayer.isPaused = !self.asteroidLayer.isPaused
            //physicsWorld.speed = 0
            
            //pauseTheGame()
            
        }
    }
    
    func timeToIntervalDistance(distance: CGFloat, speed: CGFloat) -> TimeInterval{
        let time = distance / speed
        return TimeInterval(time)
        
    }
    
    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat{
        
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }
    
    func createAsteroid() -> SKSpriteNode{
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.zPosition = 1
        
        let randomScale = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 6)) / 8
        
        asteroid.xScale = randomScale
        asteroid.yScale = randomScale
        
        asteroid.position.x = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: Int(UIScreen.main.bounds.width)))
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid"
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * 100.0
        
        return asteroid
    }
    
    override func update(_ currentTime: TimeInterval) {
        
//        let asteroid = createAsteroid()
//        addChild(asteroid)
    }
    
    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodes(withName: "asteroid") { asteroid, stop in
            let heightScreen = UIScreen.main.bounds.height
            if asteroid.position.y < -heightScreen {
                asteroid.removeFromParent()
                
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
                
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact")
        
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    
}
