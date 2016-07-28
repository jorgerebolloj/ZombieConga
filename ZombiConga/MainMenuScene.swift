//
//  MainMenuScene.swift
//  ZombiConga
//
//  Created by Jorge Rebollo J on 25/07/16.
//  Copyright © 2016 RGStudio. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        var background: SKSpriteNode
        
        background = SKSpriteNode(imageNamed: "MainMenu")
        
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        addChild(background)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let transition = SKTransition.doorsOpenHorizontalWithDuration(2.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
