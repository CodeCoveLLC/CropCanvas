//
//  MarketController.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Foundation
import Vapor

class MarketController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let market = routes.grouped("market")
        market.get(use: getRates)
    }
    
    func getRates(_ req: Request) async throws -> [Market.ItemRate] {
        return Market.rates
    }
}
