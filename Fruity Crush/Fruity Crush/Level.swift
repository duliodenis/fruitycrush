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
    // These level values are found in the JSON file
    var targetScore = 0
    var maximumMoves = 0
    
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
                
                targetScore  = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
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
    
    
    // MARK: Private Score Function
    
    private func calculateScore(chains: Set<Chain>) {
        // Match-3 = 60, Match-4 = 120, Match-5 = 180, ...
        for chain in chains {
            chain.score = 60 * (chain.length - 2)
        }
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
    
    
    // MARK: Match Support Functions
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        // update the model by removing any chains
        removeFruits(horizontalChains)
        removeFruits(verticalChains)
        
        // update the model by calculating the score
        calculateScore(horizontalChains)
        calculateScore(verticalChains)
        
        return horizontalChains.union(verticalChains)
    }
    
    
    func detectHorizontalMatches() -> Set<Chain> {
        // new set to contain any horizontal chains found
        var set = Set<Chain>()
        
        // loop therough the rows and columns (ignoring edges)
        for row in 0..<NumRows {
            for var column in 0..<NumColumns-2 {
                // if the next 2 fruits are the same type we have a horizontal chain
                if let fruit = fruits[column, row] {
                    let matchType = fruit.fruitType
                    if fruits[column + 1, row]?.fruitType == matchType && fruits[column + 2, row]?.fruitType == matchType {
                        let chain = Chain(chainType: .Horizontal)
                        repeat {
                            chain.addFruit(fruits[column, row]!)
                            column += 1
                        } while column < NumColumns && fruits[column, row]?.fruitType == matchType
                        
                        set.insert(chain)
                    }
                }
            }
        }
        return set
    }
    
    
    func detectVerticalMatches() -> Set<Chain> {
        // new set to contain any vertical chains found
        var set = Set<Chain>()
        
        // loop therough the columns and rows (ignoring edges)
        for column in 0..<NumColumns {
            for var row in 0..<NumRows-2 {
                // if the next 2 fruits are the same type we have a vertical chain
                if let fruit = fruits[column, row] {
                    let matchType = fruit.fruitType
                    if fruits[column, row + 1]?.fruitType == matchType && fruits[column, row + 2]?.fruitType == matchType {
                        let chain = Chain(chainType: .Vertical)
                        repeat {
                            chain.addFruit(fruits[column, row]!)
                            row += 1
                        } while row < NumRows && fruits[column, row]?.fruitType == matchType
                        
                        set.insert(chain)
                    }
                }
            }
        }
        return set
    }
    
    
    // MARK: Fruit Addition, Removal & Top Up
    
    func removeFruits(chains: Set<Chain>) {
        // for all the chains passed
        for chain in chains {
            // take each fruit and
            for fruit in chain.fruits {
                // set the element to nil
                fruits[fruit.column, fruit.row] = nil
            }
        }
    }
    
    
    // detects gaps in the game grid and shifts fruits down to pack.
    // this creates gaps at the top of the game grid.
    // Returns an array of arrays of shifted fruits due to gaps.
    // Fruits are in their new positions with gaps at the top.
    func addFruits() -> [[Fruit]]{
        var columns = [[Fruit]]()
        
        // loop through the rows from bottom to top one column at a time.
        for column in 0..<NumColumns {
            var array = [Fruit]()
            for row in 0..<NumRows {
                // if we have a tile but no fruit thats a gap that needs filling
                if tiles[column, row] != nil && fruits[column, row] == nil {
                    // scan up to find a fruit
                    for lookup in (row + 1)..<NumRows {
                        if let fruit = fruits[column, lookup] {
                            // swap the fruit with the gap
                            fruits[column, lookup] = nil
                            fruits[column, row] = fruit
                            fruit.row = row
                            
                            // each column has an array of the fallen fruits
                            // with the preservation of order - those first in
                            // the array are lower on the screen.
                            // The order is important for the animation delay.
                            array.append(fruit)
                            break // no need to scan any further up
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    
    // Add new fruits to fill up the gaps left by addFruits at the top of the columns.
    // Returns an array of ordered column fruit arrays.
    // Fruits are ordered from top down.
    func topUpFruits() -> [[Fruit]] {
        var columns = [[Fruit]]()
        var fruitType: FruitType = .Unknown
        
        // detect where we have to add new fruits
        // n gaps translates to n fruits
        for column in 0..<NumColumns {
            var array = [Fruit]()
            let index: Int = NumRows-1
            
            // scan from top to bottom ending when we find the first fruit
            for row in index.stride(to: 0, by: -1) {
                if fruits[column, row] != nil { break }
                
                // if a gap is found
                if tiles[column, row] != nil {
                    var newFruitType: FruitType
                    
                    // randomly create a new type of fruit that is not equal to the last
                    repeat {
                        newFruitType = FruitType.random()
                    } while newFruitType == fruitType
                    
                    fruitType = newFruitType
                    
                    // create the new fruit
                    let fruit = Fruit(column: column, row: row, fruitType: fruitType)
                    
                    // and add it to the game grid for this column
                    fruits[column, row] = fruit
                    // and to the return array
                    array.append(fruit)
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
}