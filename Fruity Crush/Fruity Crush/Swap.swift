//
//  Swap.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/24/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

struct Swap: CustomStringConvertible {
    let fruitA: Fruit
    let fruitB: Fruit
    
    init(fruitA: Fruit, fruitB: Fruit) {
        self.fruitA = fruitA
        self.fruitB = fruitB
    }
    
    var description: String {
        return "swap \(fruitA) with \(fruitB)"
    }
}