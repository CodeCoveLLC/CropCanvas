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
        Plot(name: "Moonlight Range", price: 500, size: 5),
        Plot(name: "Green Meadows", price: 1000, size: 10)
    ]
    
    static let seeds: [Seed] = [
        Seed(name: "Raspberries", price: 35, growthDurationSeconds: 600),
        Seed(name: "Strawberries", price: 45, growthDurationSeconds: 650),
        Seed(name: "Wheat", price: 50, growthDurationSeconds: 700),
        Seed(name: "Carrots", price: 55, growthDurationSeconds: 750),
        Seed(name: "Bell Peppers", price: 60, growthDurationSeconds: 800),
        Seed(name: "Lettuce", price: 65, growthDurationSeconds: 850),
        Seed(name: "Cucumbers", price: 70, growthDurationSeconds: 900),
        Seed(name: "Pumpkins", price: 80, growthDurationSeconds: 1000),
        Seed(name: "Watermelons", price: 90, growthDurationSeconds: 1100),
        Seed(name: "Corn", price: 100, growthDurationSeconds: 1200)
    ]
}

extension Shop {
    struct Plot: Content {
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
