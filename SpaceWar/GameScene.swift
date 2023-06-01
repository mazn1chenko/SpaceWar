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
    var starsLayer: SKNode!
    var spaceShipLayer: SKNode!
    
    
    var gameIsPaused: Bool = false
    
    var otherMethodTriggered: Bool = false {
        didSet{
            if otherMethodTriggered{
                updateSpeed()
            }
        }
    }
    func updateSpeed() -> Int{
        var asteroidSpeed = score
        if score == 0{
            asteroidSpeed = 1
        }else{
            asteroidSpeed += 1
        }
        print(asteroidSpeed)
        return asteroidSpeed
    }
    
    func pauseTheGame() {

        gameIsPaused = true
        self.asteroidLayer.isPaused = true
        physicsWorld.speed = 0
        starsLayer.isPaused = true
    }
    
    func pauseButtonPressed(sender: AnyObject){
        if !gameIsPaused {
            pauseTheGame()
            
        }else{
            
            unPauseTheGame()
        }
        
    }

    func unPauseTheGame() {
        gameIsPaused = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        starsLayer.isPaused = false

    }

    func resetTheGame() {
        score = 0
        scoreLabel.text = "Score: \(score)"

        gameIsPaused = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1

    }

    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.2)
        
        scene?.size = UIScreen.main.bounds.size
        
        backgroundSpace = SKSpriteNode(imageNamed: "space")
        backgroundSpace.zPosition = 0.1
        backgroundSpace.size = CGSize(width: UIScreen.main.bounds.width + 50, height: UIScreen.main.bounds.height + 50)
        addChild(backgroundSpace)
        
        //start
        
        let starsEmitter = SKEmitterNode(fileNamed: "Stars.sks")
        
        starsEmitter?.position = CGPoint(x: frame.midX, y: frame.height / 2)
        starsEmitter?.particlePositionRange.dx = frame.width
        starsEmitter?.advanceSimulationTime(10)
        
        starsLayer = SKNode()
        starsEmitter?.zPosition = 0.9
        addChild(starsLayer)
        
        starsLayer.addChild(starsEmitter!)

        spaceShip = SKSpriteNode(imageNamed: "plane")
        spaceShip.xScale = 1.5
        spaceShip.yScale = 1.5
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        spaceShip.blendMode = .add
        //spaceShip.zPosition = 1

        //addChild(spaceShip)
        
        let colorAction1 = SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 1)
        let colorAction2 = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 1)
        
        let colorSequenceAnimation = SKAction.sequence([colorAction1, colorAction2])
        let colorActionRepeat = SKAction.repeatForever(colorSequenceAnimation)
        spaceShip.run(colorActionRepeat)
        
        //создаем слой для космического корабля и огня
        spaceShipLayer = SKNode()
        spaceShipLayer.addChild(spaceShip)
        spaceShipLayer.zPosition = 1
        spaceShip.zPosition = 1.1
        spaceShipLayer.position = CGPoint(x: frame.midX, y: frame.height / 4)
        addChild(spaceShipLayer)
        
        
        //create fire
        let fireEmitter = SKEmitterNode(fileNamed: "Fire.sks")
        fireEmitter?.zPosition = 1.1
        fireEmitter?.position.y = -40
        fireEmitter?.targetNode = self
        spaceShipLayer.addChild(fireEmitter!)
        
        //generation asteroid
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 1
        addChild(asteroidLayer)
        
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            asteroid.name = "asteroid"
            self.asteroidLayer.addChild(asteroid)
            asteroid.zPosition = 1.1
            
        }
        var asteroidPerSecond: Double = 1


        let asteroidCreationDelay = SKAction.wait(forDuration: TimeInterval(1 / updateSpeed()), withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        self.asteroidLayer.run(asteroidRunAction)
        
        scoreLabel = SKLabelNode(text: "Score \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / scoreLabel.frame.size.width, y: 300)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameIsPaused {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                
                let distance = distanceCalc(a: spaceShip.position, b: touchLocation)
                let speed: CGFloat = 500
                let time = timeToIntervalDistance(distance: distance, speed: speed)
                let moveAction = SKAction.move(to: touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.easeInEaseOut
                
                
                spaceShipLayer.run(moveAction)
                
                let bgMoveaction = SKAction.move(to: CGPoint(x: -touchLocation.x / 100, y: -touchLocation.y / 100), duration: time)
                backgroundSpace.run(bgMoveaction)
                
            }
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
        asteroid.zPosition = 1.1
        
        let randomScale = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 6)) / 3.5
        
        asteroid.xScale = randomScale
        asteroid.yScale = randomScale
        
        asteroid.position.x = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 16))
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid"
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 2.5
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * 100
        
        return asteroid
    }
    
//    override func update(_ currentTime: TimeInterval) {
//
//        let asteroid = createAsteroid()
//        addChild(asteroid)
//    }
    
    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodes(withName: "asteroid") { (asteroid, stop) in
            let heightScreen = self.frame.height
            if asteroid.position.y < -heightScreen {
                print("FUUUUUUUUUUUUUUUUUCK")
                asteroid.removeFromParent()
                
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
                
                
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
            
            otherMethodTriggered = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    
}
