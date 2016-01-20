//
//  Level.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/20/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import Foundation

// Game Board Dimensions: 9x9
let NumColumns = 9
let NumRows    = 9


class Level {
    // Level has a private array property with 81 fruits
    private var fruits = Array2D<Fruit>(columns: NumColumns, rows: NumRows)
    
    
    // The Level provides the fruit in a location of the game board
    // Note: The location may contain no fruit (nil) hence the optional.
    
    func fruitAt(column column: Int, row: Int) -> Fruit? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return fruits[column, row]
    }
    
    
    func shuffle() -> Set<Fruit> {
        return createInitialFruits()
    }
    
    
    // Fill up the level with random fruit and returns a set of fruit.
    
    private func createInitialFruits() -> Set<Fruit> {
        var set = Set<Fruit>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                let fruitType = FruitType.random()
                let fruit = Fruit(column: column, row: row, fruitType: fruitType)
                
                fruits[column, row] = fruit
                set.insert(fruit)
            }
        }
        
        return set
    }
}