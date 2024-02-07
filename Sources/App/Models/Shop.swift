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
        Plot(id: 2, name: "Green Meadows", price: 1000, size: 10),
        Plot(id: 3, name: "Sunrise Fields", price: 2000, size: 15),
        Plot(id: 4, name: "Golden Grove", price: 4000, size: 20),
        Plot(id: 5, name: "Harvest Haven", price: 8000, size: 25),
        Plot(id: 6, name: "Azure Acres", price: 16_000, size: 30),
        Plot(id: 7, name: "Crimson Fields", price: 32_000, size: 35),
        Plot(id: 8, name: "Sunny Orchard", price: 64_000, size: 40),
        Plot(id: 9, name: "Mystic Meadow", price: 128_000, size: 45),
        Plot(id: 10, name: "Rainbow Ranch", price: 256_000, size: 50),
        Plot(id: 11, name: "Tranquil Terrace", price: 512_000, size: 60),
        Plot(id: 12, name: "Whispering Woods", price: 1_024_000, size: 100),
    ]
    
    static let seeds: [String: Seed] = [
        "Pomegranate Seeds": Seed(name: "Pomegranate Seeds", price: 35, growthDurationSeconds: 600),
        "Potato Seeds": Seed(name: "Potato Seeds", price: 45, growthDurationSeconds: 650),
        "Pepper Seeds": Seed(name: "Pepper Seeds", price: 50, growthDurationSeconds: 700),
        "Cauliflower Seeds": Seed(name: "Cauliflower Seeds", price: 55, growthDurationSeconds: 750),
        "Pumpkin Seeds": Seed(name: "Pumpkin Seeds", price: 60, growthDurationSeconds: 800),
        "Carrot Seeds": Seed(name: "Carrot Seeds", price: 65, growthDurationSeconds: 850),
        "Wheat Seeds": Seed(name: "Wheat Seeds", price: 70, growthDurationSeconds: 900),
        "Blueberry Seeds": Seed(name: "Blueberry Seeds", price: 80, growthDurationSeconds: 1000),
        "Melon Seeds": Seed(name: "Melon Seeds", price: 90, growthDurationSeconds: 1100),
        "Corn Seeds": Seed(name: "Corn Seeds", price: 100, growthDurationSeconds: 1200)
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
        
        enum CodingKeys: String, CodingKey {
            case name
            case price
            case growthDurationSeconds = "growth_duration_seconds"
        }
    }
}
