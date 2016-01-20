//
//  Fruit.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/20/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import SpriteKit


enum FruitType: Int, CustomStringConvertible {
    case Unknown = 0, Apple, Cherry, Strawberry, Pineapple, Grapes, Watermelon
    
    // returns the corresponding texture atlas filename
    var spriteName: String {
        let spriteNames = [
            "apple",
            "cherry",
            "strawberry",
            "pineapple",
            "grapes",
            "watermelon"
        ]
        
        return spriteNames[rawValue - 1] 
    }
    
    // returns the highlighted version
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    
    // for new fruits - generate a random fruit type
    
    static func random() -> FruitType {
        return FruitType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    
    // Customized Output for debugging returns the spriteName
    
    var description: String {
        return spriteName
    }
}


class Fruit: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let fruitType: FruitType
    var sprite: SKSpriteNode?
    
    // Conform to Hashable Protocol
    var hashValue: Int {
        return row*10 + column
    }
    
    
    init(column: Int, row: Int, fruitType: FruitType) {
        self.column = column
        self.row = row
        self.fruitType = fruitType
    }
    
    
    // Customized Output for debugging
    
    var description: String {
        return "type: \(fruitType) cell: (\(column), \(row))"
    }
}


// Since Fruit is Hashable conform to the Equatable Protocol

func ==(lhs: Fruit, rhs: Fruit) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}