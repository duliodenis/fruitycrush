//
//  GameScene.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/18/16.
//  Copyright (c) 2016 Dulio Denis. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // the current level - which will never be nil (!)
    var level: Level!
    
    // Tile width and height in pixels
    let TILEWIDTH:  CGFloat = 32.0
    let TILEHEIGHT: CGFloat = 36.0
    
    // Sprite Kit Node Hierarchy
    let gameLayer  = SKNode()   // base layer - container for all other layers
    let fruitLayer = SKNode()   // fruit sprite layer
    let tileLayer  = SKNode()   // tile sprite layer
    
    // for highlighting selected sprites
    var selectionSprite = SKSpriteNode()
    
    // Swipe Motion Support
    var swipeFromColumn: Int?   // Record Column and Row number of fruit first
    var swipeFromRow: Int?      // touched when swipe started
    
    // swipe handler closure to communicate with the GameVC - may be nil.
    var swipeHandler: ((Swap) -> ())?
    
    
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
        
        // the tiles are behind the fruit layer
        tileLayer.position = layerPosition
        gameLayer.addChild(tileLayer)
        
        // the fruit layer holds all the fruit sprites. the position of these
        // sprites are relative to the fruitLayer's bottom-left corner (the origin).
        fruitLayer.position = layerPosition
        gameLayer.addChild(fruitLayer)
        
        // initialize the Swipe variables - nil denotes invalid values.
        swipeFromColumn = nil
        swipeFromRow = nil
    }

    
    // add Tiles to the 
    func addTiles() {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                let tile = level.tileAt(column: column, row: row)
                if tile != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForFruit(column: column, row: row)
                    tileLayer.addChild(tileNode)
                }
            }
        }
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
    
    
    // MARK: Helper Functions for CGPoint Conversions
    
    // Helper method to convert column and row numbers into a CGPoint relative to
    // the fruit layer
    
    func pointForFruit(column column: Int, row: Int) -> CGPoint {
        return CGPoint(x: CGFloat(column) * TILEWIDTH + TILEWIDTH / 2,
                       y: CGFloat(row) * TILEHEIGHT + TILEHEIGHT / 2)
    }
    
    
    
    // Helper method to convert a CGPoint into a column and row numbers if in grid
    // Returns a tuple: (In grid (true), Column, Row) or (false (not in grid), 0, 0)
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(NumColumns) * TILEWIDTH &&
           point.y >= 0 && point.y < CGFloat(NumRows) * TILEHEIGHT {
            return (true, Int(point.x / TILEWIDTH), Int(point.y / TILEHEIGHT))
        } else {
            return (false, 0, 0) // Invalid location not on game grid
        }
    }

    
    // MARK: Touch Functions to Support Swipe Detection and Swapping Fruits
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(fruitLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            // ensure the touch is on a fruit and not on an empty tile.
            if let fruit = level.fruitAt(column: column, row: row) {
                showSelectionIndicatorForFruit(fruit)
                // Store which column and row in order to compare them later to get direction
                // and know which fruit to swipe first
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if swipeFromColumn == nil { return }
        
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(fruitLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horizontalDelta = 0, verticalDelta = 0
            
            // figure out the direction the swipe is in
            if column < swipeFromColumn! {          // Swipe Left
                horizontalDelta = -1
            } else if column > swipeFromColumn! {   // Swipe Right
                horizontalDelta = 1
            } else if row < swipeFromRow! {         // Swipe Down
                verticalDelta = -1
            } else if row > swipeFromRow! {         // Swipe Up
                verticalDelta = 1
            }
            
            // only try swapping when the player swiped into a new square
            if horizontalDelta != 0 || verticalDelta != 0 {
                trySwap(horizontal: horizontalDelta, vertical: verticalDelta)
                hideSelectionIndicator()
                
                swipeFromColumn = nil // ignore the rest of this swipe
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Remove the selection indicator with a Fade out only when the player didn't swipe.
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        
        // Reset the starting column and row when gesture ends regardless if valid swipe or not.
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
    
    
    // MARK: Swap Functions
    
    func trySwap(horizontal horizontalDelta: Int, vertical verticalDelta: Int) {
        let toColumn = swipeFromColumn! + horizontalDelta
        let toRow = swipeFromRow! + verticalDelta
        
        // Bounds protection - Ignore when player goes over the edges.
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        if let toFruit = level.fruitAt(column: toColumn, row: toRow),
           let fromFruit = level.fruitAt(column: swipeFromColumn!, row: swipeFromRow!),
           let handler = swipeHandler {
            let swap = Swap(fruitA: fromFruit, fruitB: toFruit)
            handler(swap)
        }
    }
    
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.fruitA.sprite!
        let spriteB = swap.fruitB.sprite!
        
        // origin of swap fruit (A) goes on top
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
    }
    
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.fruitA.sprite!
        let spriteB = swap.fruitB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition =  90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
    }
    
    
    // MARK: Highlighting Function
    
    func showSelectionIndicatorForFruit(fruit: Fruit) {
        // If the selection indicator is somehow still visible - remove it.
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = fruit.sprite {
            let texture = SKTexture(imageNamed: fruit.fruitType.highlightedSpriteName)
            
            selectionSprite.size = texture.size()
            // Need to run an action to give the correct size after setting
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            // make it a child of the fruit sprite to have it move in the swap animation
            sprite.addChild(selectionSprite)
            // Make highlighted sprite visible
            selectionSprite.alpha = 1.0
        }
    }
    
    
    func hideSelectionIndicator() {
    // remove the selection sprite by fading it out
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()
            ]))
    }
}
