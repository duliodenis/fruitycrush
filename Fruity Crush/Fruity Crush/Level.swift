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
    // and a private array of slots defining whether a fruit can slip in
    private var tiles  = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    
    // initialize the level with a filename
    init(filename: String) {
        // load the filename into a dictionary
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            // pull out the tiles from the dictionary
            if let tilesArray: AnyObject = dictionary["tiles"] {
                
                // step through the row with the row number in the current row
                for (row, currentRow) in (tilesArray as! [[Int]]).enumerate() {
                    // reverse the order of rows for SpriteKit since (0,0) is at the bottom
                    let tileRow = NumRows - row - 1
                    
                    // step through the columns in the current row
                    for (column, value) in currentRow.enumerate() {
                        // if 1 then create a tile object and place it into the tiles array
                        if value == 1 { tiles[column, tileRow] = Tile() }
                    }
                }
            }
        }
    }
    
    
    // The Level provides the fruit in a location of the game board
    // Note: The location may contain no fruit (nil) hence the optional.
    
    func fruitAt(column column: Int, row: Int) -> Fruit? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return fruits[column, row]
    }
    
    
    // Tiles describe which part of the grid is empty or can contain a fruit
    
    func tileAt(column column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return tiles[column, row]
    }
    
    
    func shuffle() -> Set<Fruit> {
        return createInitialFruits()
    }
    
    
    // Fill up the level with random fruit and returns a set of fruit.
    
    private func createInitialFruits() -> Set<Fruit> {
        var set = Set<Fruit>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                // check the tiles arrary to see if a fruit can be placed
                if tiles[column, row] != nil {
                    let fruitType = FruitType.random()
                    let fruit = Fruit(column: column, row: row, fruitType: fruitType)
                    
                    fruits[column, row] = fruit
                    set.insert(fruit)
                }                
            }
        }
        
        return set
    }
    
    
    // MARK: Swap Support Function
    
    func performSwap(swap: Swap) {
        let columnA = swap.fruitA.column
        let rowA = swap.fruitA.row
        
        let columnB = swap.fruitB.column
        let rowB = swap.fruitB.row
        
        // Swap B -> A, A -> B in the fruits[] array
        fruits[columnA, rowA] = swap.fruitB
        swap.fruitB.column = columnA
        swap.fruitB.row = rowA
        
        fruits[columnB, rowB] = swap.fruitA
        swap.fruitA.column = columnB
        swap.fruitA.row = rowB        
    }
}