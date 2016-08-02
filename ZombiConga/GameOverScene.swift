//
//  GameOverScene.swift
//  ZombiConga
//
//  Created by Jorge Rebollo J on 25/07/16.
//  Copyright © 2016 RGStudio. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    let hasWon: Bool
    
    init(size: CGSize, hasWon:Bool) {
        self.hasWon = hasWon
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) no ha sido implementado. ERROR!")
    }
    
    override func didMoveToView(view: SKView) {
        var background: SKSpriteNode
        
        if (hasWon) {
            background = SKSpriteNode(imageNamed: "YouWin")
            runAction(SKAction.sequence([SKAction.waitForDuration(0.25), SKAction.playSoundFileNamed("win", waitForCompletion: false)]))
        } else {
            background = SKSpriteNode(imageNamed: "YouLose")
            runAction(SKAction.sequence([SKAction.waitForDuration(0.25), SKAction.playSoundFileNamed("lose", waitForCompletion: false)]))
        }
        
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        addChild(background)
        
        let waitAction = SKAction.waitForDuration(4.0)
        let blockAction = SKAction.runBlock {
            let gameScene = MainMenuScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
            let transition = SKTransition.flipHorizontalWithDuration(1.0)
            self.view?.presentScene(gameScene, transition: transition)
        }
        
        self.runAction(SKAction.sequence([waitAction, blockAction]))
    }
}