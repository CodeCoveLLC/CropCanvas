//
//  ShopController.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor
import Fluent

class ShopController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let shop = routes.grouped("shop")
        shop.get("plots", use: getShopPlots)
        shop.get("seeds", use: getShopSeeds)
    }
    
    func getShopPlots(_ req: Request) async throws -> Response {
        let profile = try await req.getProfile(with: { query in
            query.with(\.$plots)
        })
        
        let potentialItems = Shop.plots.filter { shopPlot in
            !profile.plots.contains { ownedPlot in
                ownedPlot.name == shopPlot.name
            }
        }
        
        return try await ShopInventoryResponse(
            balance: profile.balance,
            numberOfItems: potentialItems.count,
            items: potentialItems
        ).encodeResponse(for: req)
    }
    
    func getShopSeeds(_ req: Request) async throws -> Response {
        let profile = try await req.getProfile()
        
        return try await ShopInventoryResponse(
            balance: profile.balance,
            numberOfItems: Shop.seeds.count,
            items: Shop.seeds
        ).encodeResponse(for: req)
    }
    
    private struct ShopInventoryResponse<Product: Content>: Content {
        let balance: Int
        let numberOfItems: Int
        let items: [Product]?
        
        enum CodingKeys: String, CodingKey {
            case balance
            case numberOfItems = "number_of_items"
            case items
        }
    }
}
