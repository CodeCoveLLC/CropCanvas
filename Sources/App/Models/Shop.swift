//
//  Shop.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Foundation
import Vapor

enum Shop {
    static let plots: [Plot] = [
        Plot(id: 1, name: "Moonlight Range", price: 500, size: 5),
        Plot(id: 2, name: "Green Meadows", price: 1000, size: 10)
    ]
    
    static let seeds: [Seed] = [
        Seed(name: "Raspberry Seeds", price: 35, growthDurationSeconds: 600),
        Seed(name: "Strawberry Seeds", price: 45, growthDurationSeconds: 650),
        Seed(name: "Wheat Seeds", price: 50, growthDurationSeconds: 700),
        Seed(name: "Carrot Seeds", price: 55, growthDurationSeconds: 750),
        Seed(name: "Bell Pepper Seeds", price: 60, growthDurationSeconds: 800),
        Seed(name: "Lettuce Seeds", price: 65, growthDurationSeconds: 850),
        Seed(name: "Cucumber Seeds", price: 70, growthDurationSeconds: 900),
        Seed(name: "Pumpkin Seeds", price: 80, growthDurationSeconds: 1000),
        Seed(name: "Watermelon Seeds", price: 90, growthDurationSeconds: 1100),
        Seed(name: "Corn Seeds", price: 100, growthDurationSeconds: 1200)
    ]
}

extension Shop {
    struct Plot: Content {
        let id: Int
        let name: String
        let price: Int
        let size: Int
    }
    
    struct Seed: Content {
        let name: String
        let price: Int
        let growthDurationSeconds: Int
    }
}
