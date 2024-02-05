//
//  Market.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Foundation
import Vapor

enum Market {
    
    static let rates: [ItemRate] = [                                      // ((Cost * Time) / 1000) / 2) - Cost = Profit
        ItemRate(name: "Raspberries", baseWorth: 105, marketRate: 1.0),   // 210 / 2  = 105 - 35  = 70
        ItemRate(name: "Strawberries", baseWorth: 145, marketRate: 1.0),  // 290 / 2  = 145 - 45  = 100
        ItemRate(name: "Wheat", baseWorth: 175, marketRate: 1.0),         // 350 / 2  = 175 - 50  = 125
        ItemRate(name: "Carrots", baseWorth: 210, marketRate: 1.0),       // 420 / 2  = 210 - 55  = 155
        ItemRate(name: "Bell Peppers", baseWorth: 240, marketRate: 1.0),  // 480 / 2  = 240 - 60  = 180
        ItemRate(name: "Lettuce", baseWorth: 275, marketRate: 1.0),       // 550 / 2  = 275 - 65  = 210
        ItemRate(name: "Cucumbers", baseWorth: 315, marketRate: 1.0),     // 630 / 2  = 315 - 70  = 245
        ItemRate(name: "Pumpkins", baseWorth: 400, marketRate: 1.0),      // 800 / 2  = 400 - 80  = 320
        ItemRate(name: "Watermelons", baseWorth: 495, marketRate: 1.0),   // 990 / 2  = 495 - 90  = 405
        ItemRate(name: "Corn", baseWorth: 600, marketRate: 1.0)           // 1200 / 2 = 600 - 100 = 500
    ]
    
    struct ItemRate: Content {
        var name: String
        var baseWorth: Int
        var marketRate: Double
        
        enum CodingKeys: String, CodingKey {
            case name
            case baseWorth = "base_worth"
            case marketRate = "market_rate"
        }
    }
}
