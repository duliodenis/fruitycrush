//
//  GameScene.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/18/16.
//  Copyright (c) 2016 Dulio Denis. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Breve SC")
        myLabel.text = "Fruity Crush Saga"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
    }

}
