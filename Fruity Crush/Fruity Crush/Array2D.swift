//
//  Array2D.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/20/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import Foundation

struct Array2D<T> {
// Generic Array for the 9x9 Grid Game Board used for fruits and tiles
    let columns: Int
    let rows: Int
    
    // array can contain nil values - hence, declared optional
    private var array: Array<T?>
    
    // initializer takes the rows and columns to create the grid
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    
    // Index the array with subscripts to get to say fruits[3,2]
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        
        set {
            array[row*columns + column] = newValue
        }
    }
}