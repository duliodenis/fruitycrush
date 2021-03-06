//
//  GameViewController.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/18/16.
//  Copyright (c) 2016 Dulio Denis. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    var level: Level!
    var scene: GameScene!
    
    var movesRemaining = 0
    var score = 0
    
    var click: AVAudioPlayer!
    
    // Game UI Labels
    @IBOutlet weak var movesLabel:  UILabel!
    @IBOutlet weak var scoreLabel:  UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var shuffleButton: RoundedButton!

    // Game Poster: Level Complete or Game Over
    @IBOutlet weak var gameOverPoster: UIImageView!
    
    // tap gesture to dismiss game completion poster
    var tapGestureRecognizer: UITapGestureRecognizer!
    
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
        
        // hide the game completion poster
        gameOverPoster.hidden = true
        
        // and hide the shuffle button
        shuffleButton.hidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Add any game sounds
        addSound()
        
        // kick the game off
        beginGame()
    }
    
    
    // MARK: Game Lifecycle
    
    func beginGame() {
        movesRemaining = level.maximumMoves
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
        }
        shuffle()
    }
    
    
    func shuffle() {
        let newFruits = level.shuffle()
        scene.removeAllFruitSprites()
        scene.addSpritesForFruits(newFruits)
    }
    
    
    // MARK: Button Actions
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        click.play()
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func shuffleButtonTapped(sender: AnyObject) {
        shuffle()
        decrementMoves()
    }
    
    
    // MARK: UI Functions
    
    func updateLabels() {
        targetLabel.text = "\(level.targetScore)"
        movesLabel.text  = "\(movesRemaining)"
        scoreLabel.text  = "\(score)"
    }
    
    
    // MARK: Swap Support Function
    
    func handleMatches() {
        // remove any matching fruits and fill up the gaps with new fruits.
        // interaction is locked during this action.
        let chains = level.removeMatches()
        
        // base case of the recursion: if no more matches - player gets to move
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        
        // Animate any of the removed matches
        scene.animateMatchedFruits(chains) {
            
            // add the score of the chains to the total
            for chain in chains {
                self.score += chain.score
            }
            // and update the score label
            self.updateLabels()
            
            // then shift down any fruits
            let columns = self.level.addFruits()
            // animate the falling fruit
            self.scene.animateFallingFruits(columns) {
                // and top up any gaps in the columns
                let columns = self.level.topUpFruits()
                self.scene.animateNewFruits(columns) {
                    // recursively repeat the cycle until there are no more matches
                    self.handleMatches()
                }
            }
        }
    }
    
    
    // yield control to the player
    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        decrementMoves()
        view.userInteractionEnabled = true
    }
    
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        // ensure the swap is valid - meaning it only results in a match chain.
        if level.isSwapPossible(swap) {
            // update the Level (data model)
            level.performSwap(swap)
            
            // then animate the Game Scene (View)
            scene.animateSwap(swap) { // trailing closure syntax
                self.handleMatches()
                self.view.userInteractionEnabled = true
            }
        } else { // the swap was not possible
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    
    // MARK: Move function
    
    func decrementMoves() {
        movesRemaining -= 1
        updateLabels()
        
        if score >= level.targetScore {
            gameOverPoster.image = UIImage(named: "Level-Complete")
            showGameOverPoster()
        } else if movesRemaining == 0 {
            gameOverPoster.image = UIImage(named: "Game-Over")
            showGameOverPoster()
        }
    }
    
    
    // MARK: Game Completion Poster Function
    
    func showGameOverPoster() {
        gameOverPoster.hidden = false
        scene.userInteractionEnabled = false
        shuffleButton.hidden = true
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOverPoster")
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    
    
    func hideGameOverPoster() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPoster.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
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
    
    
    func addSound() {
        // AudioPlayer for Button Click
        do {
            try click = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "wav")!))
            click.prepareToPlay()
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
}
