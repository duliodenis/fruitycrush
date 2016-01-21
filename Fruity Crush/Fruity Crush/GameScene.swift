//
//  GameScene.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/18/16.
//  Copyright (c) 2016 Dulio Denis. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // the current level
    var level: Level!
    
    // Tile width and height in pixels
    let TILEWIDTH:  CGFloat = 32.0
    let TILEHEIGHT: CGFloat = 36.0
    
    // Sprite Kit Node Hierarchy
    let gameLayer = SKNode()    // base layer - container for all other layers
    let fruitLayer = SKNode()   // fruit sprite layer
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }

    override init(size: CGSize) {
        super.init(size: size)
        
        // Center in the screen
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // white background
        backgroundColor = SKColor.whiteColor()
        
        // add the empty gameLayer to the GameScene
        addChild(gameLayer)
        
        // Move the fruit sprite layer from the default (0,0) position to 
        // down 1/2 the height and to the left of 1/2 the width of the board
        let layerPosition = CGPoint(x: -TILEWIDTH * CGFloat(NumColumns) / 2,
                                    y: -TILEHEIGHT * CGFloat(NumRows) / 2)
        
        fruitLayer.position = layerPosition
        gameLayer.addChild(fruitLayer)
    }

    
    // Iterate through a set of fruits and add the SKSpiteNode to the fruit layer
    
    func addSpritesForFruits(fruits: Set<Fruit>) {
        for fruit in fruits {
            let sprite = SKSpriteNode(imageNamed: fruit.fruitType.spriteName)
            sprite.position = pointForFruit(column: fruit.column, row: fruit.row)
            fruitLayer.addChild(sprite)
            fruit.sprite = sprite
        }
    }
    
    
    // Helper method to convert column and row numbers into a CGPoint relative to
    // the fruit layer
    
    func pointForFruit(column column: Int, row: Int) -> CGPoint {
        return CGPoint(x: CGFloat(column) * TILEWIDTH + TILEWIDTH / 2,
                       y: CGFloat(row) * TILEHEIGHT + TILEHEIGHT / 2)
    }
}
