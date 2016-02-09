//
//  Chain.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 2/1/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    // the fruits that are part of this chain
    var fruits = [Fruit]()
    
    // how many points this chain is worth
    var score = 0
    
    enum ChainType: CustomStringConvertible {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal:   return "Horizontal"
            case .Vertical:     return "Vertical"
            }
        }
    }
    
    // Whether this chain is either horizontal or vertical
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addFruit(fruit: Fruit) {
        fruits.append(fruit)
    }
    
    func firstFruit() -> Fruit {
        return fruits[0]
    }
    
    func lastFruit() -> Fruit {
        return fruits[fruits.count - 1]
    }
    
    var length: Int {
        return fruits.count
    }
    
    var description: String {
        return "type: \(chainType) fruits: \(fruits)"
    }
    
    var hashValue: Int {
        return fruits.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
}

// Since Chain is Hashable conform to the Equatable Protocol
func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.fruits == rhs.fruits
}
