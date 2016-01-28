//
//  Swap.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/24/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

struct Swap: CustomStringConvertible, Hashable {
    let fruitA: Fruit
    let fruitB: Fruit
    
    // Conform to Hashable Protocol
    var hashValue: Int {
        // exclusive-or combination
        return fruitA.hashValue ^ fruitB.hashValue
    }
    
    init(fruitA: Fruit, fruitB: Fruit) {
        self.fruitA = fruitA
        self.fruitB = fruitB
    }
    
    var description: String {
        return "swap \(fruitA) with \(fruitB)"
    }
}

// Since Swap is Hashable conform to the Equatable Protocol

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.fruitA == rhs.fruitA && lhs.fruitB == rhs.fruitB) ||
           (lhs.fruitB == rhs.fruitA && lhs.fruitA == rhs.fruitB)
}