//
//  ContentView.swift
//  Apple Catching Game
//
//  Created by Ujwal Chilla on 1/19/22.
//

import SwiftUI
import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let userDefaults = UserDefaults()
    
    let background = SKSpriteNode(imageNamed: "AppleCatchingBackground")
    var player = SKSpriteNode()
    var apple = SKSpriteNode()
    var bottom = SKSpriteNode()
    var heart = SKSpriteNode()
    var ten = SKSpriteNode()
    var lightning = SKSpriteNode()
    var restart = SKSpriteNode()
    
    var appleTimer = Timer()
    var heartTimer = Timer()
    var tenTimer = Timer()
    var lightningTimer = Timer()
    var lightningCatchedTimer = Timer()
    var appleTimerLightningCaught = Timer()
    
    var ligthningIsOn = false
    
    var livesLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    struct CBitmask {
        
        static let player: UInt32 = 0b1
        static let apple: UInt32 = 0b10
        static let lightning: UInt32 = 0b1000
        static let ten: UInt32 = 0b10000
        static let heart: UInt32 = 0b100000
        static let bottom: UInt32 = 0b100
        
    }
    
    var lives = 5 {
        
        didSet{
            
            livesLabel.text = "Lives: \(lives)"
            
        }
        
    }
    
    var score = 0 {
        
        didSet{
            
            scoreLabel.text = "Score: \(score)"
            
        }
        
    }
    
    override func didMove(to view: SKView){
        
        physicsWorld.contactDelegate = self
        scene?.size = CGSize(width: 750, height: 1335)
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.setScale(3.3)
        addChild(background)
        
        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontSize = 50
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: 280, y: 1200)
        addChild(livesLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 50
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 280, y: 1100)
        addChild(scoreLabel)
        
        makePlayer()
        makeBottom()
        
        appleTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeApples), userInfo: nil, repeats: true)
        heartTimer = .scheduledTimer(timeInterval: 5, target: self, selector: #selector(makeHeart), userInfo: nil, repeats: true)//25 15 35
        tenTimer = .scheduledTimer(timeInterval: 8, target: self, selector: #selector(makeTen), userInfo: nil, repeats: true)
        lightningTimer = .scheduledTimer(timeInterval: 11, target: self, selector: #selector(makeLightning), userInfo: nil, repeats: true)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            contactA = contact.bodyA
            contactB = contact.bodyB
            
        } else {
            
            contactA = contact.bodyB
            contactB = contact.bodyA
            
        }
        
        if contactA.categoryBitMask == CBitmask.player && contactB.categoryBitMask == CBitmask.apple {
            
            appleCatched(players: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
                        
        }
        
        if contactA.categoryBitMask == CBitmask.player && contactB.categoryBitMask == CBitmask.ten {
            
            plusTenCatched(players: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
                        
        }
        
        if contactA.categoryBitMask == CBitmask.player && contactB.categoryBitMask == CBitmask.heart {
            
            heartCatched(players: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
                        
        }
        
        if contactA.categoryBitMask == CBitmask.player && contactB.categoryBitMask == CBitmask.lightning {

            lightningCatched(players: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)

        }
        
        if contactA.categoryBitMask == CBitmask.bottom && contactB.categoryBitMask == CBitmask.apple {
            
            appleHitBottom(bottoms: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
            
        } else if contactB.categoryBitMask == CBitmask.bottom && contactA.categoryBitMask == CBitmask.apple {
            
            appleHitBottom(bottoms: contactB.node as! SKSpriteNode, apples: contactA.node as! SKSpriteNode)
            
        }
        
        if contactA.categoryBitMask == CBitmask.bottom && contactB.categoryBitMask == CBitmask.ten {
            
            powerUpHitBottom(bottoms: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
            
        } else if contactB.categoryBitMask == CBitmask.bottom && contactA.categoryBitMask == CBitmask.ten {
            
            powerUpHitBottom(bottoms: contactB.node as! SKSpriteNode, apples: contactA.node as! SKSpriteNode)
            
        }
        
        if contactA.categoryBitMask == CBitmask.bottom && contactB.categoryBitMask == CBitmask.heart {
            
            powerUpHitBottom(bottoms: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
            
        } else if contactB.categoryBitMask == CBitmask.bottom && contactA.categoryBitMask == CBitmask.heart {
            
            powerUpHitBottom(bottoms: contactB.node as! SKSpriteNode, apples: contactA.node as! SKSpriteNode)
            
        }
        
        if contactA.categoryBitMask == CBitmask.bottom && contactB.categoryBitMask == CBitmask.lightning {
            
            powerUpHitBottom(bottoms: contactA.node as! SKSpriteNode, apples: contactB.node as! SKSpriteNode)
            
        } else if contactB.categoryBitMask == CBitmask.bottom && contactA.categoryBitMask == CBitmask.lightning {
            
            powerUpHitBottom(bottoms: contactB.node as! SKSpriteNode, apples: contactA.node as! SKSpriteNode)
            
        }
        
    }
    
    func appleCatched (players: SKSpriteNode, apples: SKSpriteNode) {
        
        apples.removeFromParent()
        
        score += 1
        
    }
    
    func plusTenCatched (players: SKSpriteNode, apples: SKSpriteNode) {
        
        apples.removeFromParent()
        
        score += 10
        
    }
    
    func heartCatched (players: SKSpriteNode, apples: SKSpriteNode) {
        
        apples.removeFromParent()
        
        lives += 1
        
    }
    
    var time = 10
    
    @objc func countdown() {
        
        ligthningIsOn = true
        
        time -= 1
        
        appleTimer.invalidate()
        appleTimerLightningCaught.invalidate()
        
        appleTimerLightningCaught = .scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(makeApples), userInfo: nil, repeats: true)

        if time <= 0 {
            
            ligthningIsOn = false
            
            time = 10
            
            lightningCatchedTimer.invalidate()
            appleTimerLightningCaught.invalidate()
            
            appleTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeApples), userInfo: nil, repeats: true)
            
        }
        
    }
    
    func lightningCatched (players: SKSpriteNode, apples: SKSpriteNode) {
        
        apples.removeFromParent()
        
        score += 1

        lightningCatchedTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        
    }
    
    
    func appleHitBottom (bottoms: SKSpriteNode, apples: SKSpriteNode) {
        
        apples.removeFromParent()
        
        if !ligthningIsOn{
        
            lives -= 1
        
        }
        if lives <= 0 {

            gameOver()

        }
        
    }
    
    func powerUpHitBottom (bottoms: SKSpriteNode, apples: SKSpriteNode) {
        
        apples.removeFromParent()
        
    }
    
    var highscore = 0
    
    func gameOver(){
        
        if let value = userDefaults.value(forKey: "highscore") as? Int {
            
            highscore = value
            
        }
        
        if score > highscore{
            
            highscore = score
            
        }
        
        appleTimer.invalidate()
        lightningTimer.invalidate()
        tenTimer.invalidate()
        heartTimer.invalidate()
        
        lives = 0
        
        player.removeFromParent()
        bottom.removeFromParent()
        
        livesLabel.text = "High Score: \(highscore)"
        
        livesLabel.setScale(1.5)
        scoreLabel.setScale(1.5)

        livesLabel.position = CGPoint(x: 600, y: 1200)
        scoreLabel.position = CGPoint(x: 500, y: 1000)
        
        restart = .init(imageNamed: "AppleCatchingRestart")
        restart.position = CGPoint(x: 370, y: 830)
        restart.setScale(0.25)
        restart.zPosition = 30
        restart.name = "restart"
        restart.isUserInteractionEnabled = false
        
        userDefaults.setValue(highscore, forKey: "highscore")
        
        addChild(restart)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
        
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            
            if node.name == "restart" {
                
                restart.removeFromParent()
            
                makePlayer()
                makeBottom()
                
                appleTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeApples), userInfo: nil, repeats: true)
                heartTimer = .scheduledTimer(timeInterval: 15, target: self, selector: #selector(makeHeart), userInfo: nil, repeats: true)
                tenTimer = .scheduledTimer(timeInterval: 20, target: self, selector: #selector(makeTen), userInfo: nil, repeats: true)
                lightningTimer = .scheduledTimer(timeInterval: 35, target: self, selector: #selector(makeLightning), userInfo: nil, repeats: true)
                
                lives = 5
                score = 0
                
                livesLabel.text = "Lives: \(lives)"
                livesLabel.setScale(1)
                livesLabel.position = CGPoint(x: 280, y: 1200)
                
                scoreLabel.text = "Score: \(score)"
                scoreLabel.setScale(1)
                scoreLabel.position = CGPoint(x: 280, y: 1100)
                
            }
        
        }
        
    }
    
    func makePlayer(){
        
        player = .init(imageNamed: "AppleCatchingBasket")
        player.position = CGPoint(x: size.width / 2, y: 120)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = CBitmask.player
        player.physicsBody?.contactTestBitMask = CBitmask.apple
        player.physicsBody?.collisionBitMask = CBitmask.apple
        player.setScale(0.4)
        
        addChild(player)
        
    }
    
    func makeBottom(){
        
        bottom = .init(imageNamed: "AppleCatchingBottom")
        bottom.position = CGPoint(x: 375, y: -180)
        bottom.setScale(3)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: bottom.size)
        bottom.physicsBody?.affectedByGravity = false
        bottom.physicsBody?.isDynamic = true
        bottom.physicsBody?.categoryBitMask = CBitmask.bottom
        bottom.physicsBody?.contactTestBitMask = CBitmask.apple
        bottom.physicsBody?.collisionBitMask = CBitmask.apple
        
        addChild(bottom)
        
    }
    
    @objc func makeApples(){
        
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        apple = .init(imageNamed: "AppleCatchingApple")
        apple.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        apple.zPosition = 5
        apple.setScale(0.08)
        apple.physicsBody = SKPhysicsBody(rectangleOf: apple.size)
        apple.physicsBody?.affectedByGravity = false
        apple.physicsBody?.categoryBitMask = CBitmask.apple
        apple.physicsBody?.contactTestBitMask = CBitmask.player | CBitmask.bottom
        apple.physicsBody?.collisionBitMask = CBitmask.player | CBitmask.bottom
        
        addChild(apple)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        apple.run(combine)
        
    }
    
    @objc func makeHeart(){
        
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        heart = .init(imageNamed: "AppleCatchingHeart")
        heart.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        heart.zPosition = 5
        heart.setScale(0.1)
        heart.physicsBody = SKPhysicsBody(rectangleOf: heart.size)
        heart.physicsBody?.affectedByGravity = false
        heart.physicsBody?.categoryBitMask = CBitmask.heart
        heart.physicsBody?.contactTestBitMask = CBitmask.player | CBitmask.bottom
        heart.physicsBody?.collisionBitMask = CBitmask.player | CBitmask.bottom
        
        addChild(heart)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        heart.run(combine)
        
    }
    
    @objc func makeTen(){
        
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        ten = .init(imageNamed: "AppleCatchingPlusTen")
        ten.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        ten.zPosition = 5
        ten.setScale(0.17)
        ten.physicsBody = SKPhysicsBody(rectangleOf: ten.size)
        ten.physicsBody?.affectedByGravity = false
        ten.physicsBody?.categoryBitMask = CBitmask.ten
        ten.physicsBody?.contactTestBitMask = CBitmask.player | CBitmask.bottom
        ten.physicsBody?.collisionBitMask = CBitmask.player | CBitmask.bottom
        
        addChild(ten)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        ten.run(combine)
        
    }
    
    @objc func makeLightning(){
        
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
        
        lightning = .init(imageNamed: "AppleCatchingLightning")
        lightning.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
        lightning.zPosition = 5
        lightning.setScale(0.15)
        lightning.physicsBody = SKPhysicsBody(rectangleOf: lightning.size)
        lightning.physicsBody?.affectedByGravity = false
        lightning.physicsBody?.categoryBitMask = CBitmask.lightning
        lightning.physicsBody?.contactTestBitMask = CBitmask.player | CBitmask.bottom
        lightning.physicsBody?.collisionBitMask = CBitmask.player | CBitmask.bottom
        
        addChild(lightning)
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
        let deleteAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction, deleteAction])
        lightning.run(combine)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            player.position.x = location.x
            
        }
        
    }
    
}

struct ContentView: View {
    
    let scene = GameScene()
    
    var body: some View {
        
        
        ZStack{

            SpriteView(scene: scene).ignoresSafeArea()
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
    
        ContentView()
    
    }

}
