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
        level = Level()
        scene.level = level
        
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
