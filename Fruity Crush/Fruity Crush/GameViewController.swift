//
//  GameViewController.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/18/16.
//  Copyright (c) 2016 Dulio Denis. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var level: Level!
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Create the Level object
        level = Level(filename: "Level_1")
        scene.level = level
        scene.addTiles()
        
        // Assign the handleSwipe() function to GameScene's swipeHandler property
        scene.swipeHandler = handleSwipe
        
        // Present the scene.
        skView.presentScene(scene)
        
        // kick the game off
        beginGame()
    }
    
    
    // MARK: Game Lifecycle
    
    func beginGame() {
        shuffle()
    }
    
    
    func shuffle() {
        let newFruits = level.shuffle()
        scene.addSpritesForFruits(newFruits)
    }
    
    
    // MARK: Swap Support Function
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        // ensure the swap is valid - meaning it only results in a match chain.
        if level.isSwapPossible(swap) {
            // update the Level (data model)
            level.performSwap(swap)
            
            // then animate the Game Scene (View)
            scene.animateSwap(swap) { // trailing closure syntax
                self.view.userInteractionEnabled = true
            }
        } else { // the swap was not possible
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    
    // MARK: Boilerplate Functions
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
