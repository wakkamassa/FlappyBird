//
//  GameScene.swift
//  FlappyBird
//
//  Created by 　若原　昌史 on 2018/02/24.
//  Copyright © 2018年 WakaharaMasashi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate{
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    var item:SKSpriteNode!
    var itemNode:SKNode!
    
    var score = 0
    
    let userDefaults:UserDefaults = UserDefaults.standard
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    
    var itemScore = 0
    var itemScoreLabelNode:SKLabelNode!
    
    let birdCategory:UInt32 = 1<<0
    let groundCategory:UInt32 = 1<<1
    let wallCategory:UInt32 = 1<<2
    let scoreCategory:UInt32 = 1<<3
    let itemCategory:UInt32 = 1<<4
    
    let actionMusic = SKAction.playSoundFileNamed("1013",waitForCompletion:true)
    
    override func didMove(to view:SKView){
        
        scrollNode = SKNode()
        addChild(scrollNode)
        
        itemNode = SKNode()
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        scrollNode.addChild(itemNode)
        
        physicsWorld.gravity = CGVector(dx:0.0,dy:-4.0)
        physicsWorld.contactDelegate = self
        
        let backgroundMusic = SKAction.playSoundFileNamed("8839",waitForCompletion: true)
        let musicForever = SKAction.repeatForever(backgroundMusic)
        scrollNode.run(musicForever)
        
       
        
        setUpGround()
        setUpCloud()
        setUpWall()
        setUpBird()
        setUpScoreLabel()
        setUpItem()
        setUpItemScoreLabel()
        
    }
    
    func setUpGround(){
       
      
    let groundTexture = SKTexture(imageNamed:"ground")
    groundTexture.filteringMode = .nearest
    backgroundColor = UIColor(red:0.15,green:0.75,blue:0.9,alpha:1.0)
    let needNumber = Int(self.frame.size.width/groundTexture.size().width) + 2
        
        let moveGround = SKAction.moveBy(x:-groundTexture.size().width,y:0,duration:5.0)
        let restGround = SKAction.moveBy(x:groundTexture.size().width,y:0,duration:0.0)
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,restGround]))
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture:groundTexture)
        sprite.position = CGPoint(
        x: groundTexture.size().width * (CGFloat(i)+0.5),
                              y: groundTexture.size().height * 0.5
        )
            
             sprite.run(repeatScrollGround)
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            sprite.physicsBody?.isDynamic = false
            
                 scrollNode.addChild(sprite)
        }
    }
    
    func setUpCloud(){
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        let needCloudNumber = Int(self.frame.size.width/cloudTexture.size().width) + 2
        
        let moveCloud = SKAction.moveBy(x:-cloudTexture.size().width,y:0,duration:20.0)
        let resetCloud = SKAction.moveBy(x:cloudTexture.size().width,y:0,duration:0)
        let resetScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
        
        for i in 0..<needCloudNumber{
            let sprite = SKSpriteNode(texture:cloudTexture)
            sprite.zPosition = -100
            sprite.position = CGPoint(
                x:cloudTexture.size().width * (CGFloat(i)+0.5),
                y:self.frame.size.height - cloudTexture.size().height * 0.5
            )
            
            sprite.run(resetScrollCloud)
            scrollNode.addChild(sprite)
            
        }
    }
    
    func setUpWall(){
        let wallTexture = SKTexture(imageNamed:"wall")
        wallTexture.filteringMode = .linear
        
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        let moveWall = SKAction.moveBy(x:-movingDistance,y:0,duration:4.0)
        let removeAction = SKAction.removeFromParent()
        let wallAnimation = SKAction.sequence([moveWall,removeAction])
        
        let createWallAnimation = SKAction.run({
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width/2,y:0.0)
            wall.zPosition = -50.0
            let center_y = self.frame.size.height/2
            let random_y_range = self.frame.size.height/4
            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height/2 - random_y_range/2)
            let random_y = arc4random_uniform(UInt32(random_y_range))
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            let slit_length = self.frame.size.height / 6
            
            let under = SKSpriteNode(texture:wallTexture)
            under.position = CGPoint(x:0,y:under_wall_y)
            wall.addChild(under)
            under.physicsBody = SKPhysicsBody(rectangleOf:wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false
            
            let upper = SKSpriteNode(texture:wallTexture)
            upper.position = CGPoint(x:0.0,y:under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf:wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
        
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x:upper.size.width + self.bird.size.width/2,y:self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width:upper.size.width,height:self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        let waitAnimation = SKAction.wait(forDuration:2.0)
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
    
    func setUpBird(){
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed:"bird_b")
        birdTextureB.filteringMode = .linear
        
        let texturesAnimation = SKAction.animate(with:[birdTextureA,birdTextureB],timePerFrame:0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        bird = SKSpriteNode(texture:birdTextureA)
        bird.position = CGPoint(x:self.frame.size.width * 0.2,y:self.frame.size.height * 0.7)
        
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
        
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        bird.run(flap)
        
        addChild(bird)
    }

    // item生成メソッド
    func setUpItem(){
            let random_position = arc4random_uniform(5)
 
        let createRandomItem = SKAction.run({
            let itemTexture = SKTexture(imageNamed:"classical_apple")
            itemTexture.filteringMode = .linear
            self.item =  SKSpriteNode(texture:itemTexture)
            let moveDistance = CGFloat(itemTexture.size().width + self.frame.size.width)
            let moveItem = SKAction.moveBy(x: -moveDistance, y: 0, duration: 4.0)
            let waitTime = SKAction.wait(forDuration :3)
            let removeAction = SKAction.removeFromParent()
            let itemAnimation = SKAction.sequence([moveItem,waitTime, removeAction])
            self.item.physicsBody = SKPhysicsBody(circleOfRadius:self.item.size.height / 2)
            self.item.physicsBody?.isDynamic = false
            self.item.physicsBody?.categoryBitMask = self.itemCategory
            self.item.physicsBody?.contactTestBitMask = self.birdCategory
            self.item.physicsBody?.collisionBitMask = self.wallCategory | self.groundCategory
            self.item.position = CGPoint(x:CGFloat(random_position * 150),y:CGFloat(random_position * 150))
            self.item.zPosition = 10
            self.item.run(itemAnimation)
            self.itemNode.addChild(self.item)
        })
        
        let waitAnimation = SKAction.wait(forDuration:TimeInterval(random_position))
        
        let repeatItemCreate = SKAction.repeatForever(SKAction.sequence([createRandomItem ,waitAnimation]))
        self.itemNode.run(repeatItemCreate)
        
        
    }
    
    
    func setUpScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x:10,y:self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "SCORE:\(score)"
        self.addChild(scoreLabelNode)
        
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x:10,y:self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "BEST SCORE:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    //アイテムスコアメソッド
    func setUpItemScoreLabel(){
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x:10,y:self.frame.size.height - 30)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "APPLE:\(itemScore)"
        addChild(itemScoreLabelNode)

    }
    
    
    override func touchesBegan(_ touches:Set<UITouch>,with event:UIEvent?){
        
        if scrollNode.speed > 0{ bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.applyImpulse(CGVector(dx:0,dy:15))
        }else if bird.speed == 0{
            restart()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if scrollNode.speed == 0{
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory{
            print("スコアUP")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
        
            var bestScore = userDefaults.integer(forKey:"BEST")
            if score > bestScore{
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore,forKey:"BEST")
                userDefaults.synchronize()
                
            }
            
        }else if(contact.bodyA.categoryBitMask & itemCategory ) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory{
            self.run(actionMusic)
            let remove = SKAction.removeFromParent()
            item.run(remove)
            itemScore += 1
            itemScoreLabelNode.text = "APPLE:\(itemScore)"
            
            
        }else{
            print("Game Over")
            scrollNode.speed = 0
            bird.physicsBody?.collisionBitMask = groundCategory
            let roll = SKAction.rotate(byAngle:CGFloat(Double.pi) * CGFloat(bird.position.y ) * 0.01,duration:1)
            bird.run(roll,completion:{
                self.bird.speed = 0
                
                }
            )
        }
    }
    
    func restart(){
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        bird.position = CGPoint(x:self.frame.size.width * 0.2,y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        itemScore = 0
        itemScoreLabelNode.text = "APPLE:\(itemScore)"
        wallNode.removeAllChildren()
        itemNode.removeAllChildren()
        bird.speed = 1
        scrollNode.speed = 1

        
    }
    
}
