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
        market.put("sell", use: sellProduct)
    }
    
    private func getRates(_ req: Request) async throws -> [Market.ItemRate] {
        return Market.rates
    }
    
    private func sellProduct(_ req: Request) async throws -> SellSuccessBody {
        let sellRequest = try req.content.decode(SellRequestBody.self)
        let profile = try await req.getProfile { query in
            query.with(\.$inventory)
        }
        
        guard let currentRate = Market.rates.first(where: { $0.name == sellRequest.name })
        else { throw MarketError.unknownProduct }
        
        guard let inventory = profile.inventory,
              var product = inventory.products.first(where: { $0.name == sellRequest.name })
        else { throw MarketError.notEnoughProduct(requested: sellRequest.amount, owned: 0) }
        
        guard product.amount >= sellRequest.amount
        else { throw MarketError.notEnoughProduct(requested: sellRequest.amount, owned: product.amount) }
        
        let moneyMade = sellRequest.amount * Int(Double(currentRate.baseWorth) * currentRate.marketRate)
        profile.balance += moneyMade
        
        inventory.products.remove(product)
        if product.amount > sellRequest.amount {
            product.amount -= sellRequest.amount
            inventory.products.update(with: product )
        }
        
        try await req.db.transaction { db in
            try await inventory.update(on: db)
            try await profile.update(on: db)
        }
        
        return SellSuccessBody(sold: product.name, amountMade: moneyMade)
    }
    
    private struct SellRequestBody: Content {
        let name: String
        let amount: Int
    }
    
    private struct SellSuccessBody: Content {
        let sold: String
        let amountMade: Int
    }
    
    private enum MarketError: AbortError {
        case unknownProduct
        case notEnoughProduct(requested: Int, owned: Int)
        
        var status: HTTPResponseStatus { .badRequest }
        
        var reason: String {
            switch self {
                case .unknownProduct: "The item you are trying to sell cannot be identified. Check the spelling of the item name!"
                case .notEnoughProduct(let requested, let owned): "You are trying to sell #\(requested) items, but only have #\(owned)"
            }
        }
    }
}
