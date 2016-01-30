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
    
    // a list of all possible moves a player can make
    private var possibleSwaps = Set<Swap>()
    
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
        var set: Set<Fruit>
        
        repeat {
            set = createInitialFruits()
            detectPossibleSwaps()
            print("Possible swaps: \(possibleSwaps)")
        
        } while possibleSwaps.count == 0
        
        return set
    }
    
    
    // Fill up the level with random fruit and returns a set of fruit.
    
    private func createInitialFruits() -> Set<Fruit> {
        var set = Set<Fruit>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                // check the tiles arrary to see if a fruit can be placed
                if tiles[column, row] != nil {

                    // find a fruit type where no chains of three exist
                    var fruitType: FruitType
                    repeat { fruitType = FruitType.random() }
                    while (column >= 2 && fruits[column - 1, row]?.fruitType == fruitType &&
                                          fruits[column - 2, row]?.fruitType == fruitType)
                    ||    (row >= 2 && fruits[column, row - 1]?.fruitType == fruitType &&
                                       fruits[column, row - 2]?.fruitType == fruitType)
                    
                    // Create a new fruit and add it to the 2D Array.
                    let fruit = Fruit(column: column, row: row, fruitType: fruitType)
                    
                    fruits[column, row] = fruit
                    set.insert(fruit)
                }                
            }
        }
        
        return set
    }
    
    
    // MARK: Swap Support Function
    
    func isSwapPossible(swap: Swap) -> Bool {
        // returns true if the swap is in the set of possible swaps.
        return possibleSwaps.contains(swap)
    }
    
    
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
    
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let currentFruit = fruits[column, row] {
                    // Work our way up and to the right
                    
                    // Start with swapping with the one on the right
                    // Don't need to check the last column.
                    if column < NumColumns - 1 {
                        // No tile indicates no fruit here.
                        if let fruitOnTheRight = fruits[column + 1, row] {
                            // Swap them
                            fruits[column, row] = fruitOnTheRight
                            fruits[column + 1, row] = currentFruit
                            
                            // Check to see if either fruit is part of a chain
                            if hasChain(column: column + 1, row: row) ||
                               hasChain(column: column, row: row) {
                                set.insert(Swap(fruitA: currentFruit, fruitB: fruitOnTheRight))
                            }
                            
                            // Swap them back
                            fruits[column, row] = currentFruit
                            fruits[column + 1, row] = fruitOnTheRight
                        }
                    }
                    
                    // Next, check to see if its possible to swap with the one above
                    // Don't need to check the last row.
                    if row < NumRows - 1 {
                        if let fruitOnTop = fruits[column, row + 1] {
                            // Swap them
                            fruits[column, row] = fruitOnTop
                            fruits[column, row + 1] = currentFruit
                            
                            // Check to see if either fruit is part of a chain
                            if hasChain(column: column, row: row + 1) ||
                               hasChain(column: column, row: row) {
                                    set.insert(Swap(fruitA: currentFruit, fruitB: fruitOnTop))
                            }
                            
                            // Swap them back
                            fruits[column, row] = currentFruit
                            fruits[column, row + 1] = fruitOnTop
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    
    // MARK: Helper Method for Possible Swap Detection
    
    private func hasChain(column column: Int, row: Int) -> Bool {
        // determine whether we have three or more consecutive fruits
        let fruitType = fruits[column, row]?.fruitType
        
        // check horizontally left (-1) and right (+1)
        var horizontalLength = 1
        for index in column.stride(to: 0, by: -1) {
            if fruits[index, row]?.fruitType == fruitType {
                horizontalLength += 1
            }
        }
        for index in column.stride(to: NumColumns, by: 1) {
            if fruits[index, row]?.fruitType == fruitType {
                horizontalLength += 1
            }
        }
        // if we have more than three return chain == true
        if horizontalLength >= 3 { return true }
        
        // do the same vertically down (-1) and up (+1)
        var verticalLength = 1
        for index in row.stride(to: 0, by: -1) {
            if fruits[column, index]?.fruitType == fruitType {
                verticalLength += 1
            }
        }
        for index in row.stride(to: NumRows, by: 1) {
            if fruits[column, index]?.fruitType == fruitType {
                verticalLength += 1
            }
        }
        // if there are more than three return true indicating a chain
        if verticalLength >= 3 { return true }
        
        // if we made it this far we detected no chain - return false
        return false
    }
}