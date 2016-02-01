//
//  Audio.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/31/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import SpriteKit

struct Audio {
    // Game Sounds
    static let swap = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    static let invalidSwap = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    static let match = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    static let fallingFruits = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    static let addFruit = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
}