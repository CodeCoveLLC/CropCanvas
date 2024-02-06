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
        shop.put("plots", ":plot_id", use: purchasePlot)
        
        shop.get("seeds", use: getShopSeeds)
        shop.put("seeds", use: purchaseSeeds)
    }
    
    private func getShopPlots(_ req: Request) async throws -> ShopInventoryResponse<Shop.Plot> {
        let profile = try await req.getProfile(with: { query in
            query.with(\.$plots)
        })
        
        let potentialItems = Shop.plots.filter { shopPlot in
            !profile.plots.contains { ownedPlot in
                ownedPlot.name == shopPlot.name
            }
        }
        
        return ShopInventoryResponse(
            balance: profile.balance,
            numberOfItems: potentialItems.count,
            items: potentialItems
        )
    }
    
    private func getShopSeeds(_ req: Request) async throws -> ShopInventoryResponse<Shop.Seed> {
        let profile = try await req.getProfile()
        
        return ShopInventoryResponse(
            balance: profile.balance,
            numberOfItems: Shop.seeds.count,
            items: Array(Shop.seeds.values)
        )
    }
    
    private func purchasePlot(_ req: Request) async throws -> PurchaseSuccessful<Plot> {
        guard let plotID = req.parameters.get("plot_id", as: Int.self),
              let shopPlot = Shop.plots.first(where: { $0.id == plotID })
        else { throw ShopError.unknownPlot }
        
        let profile = try await req.getProfile { query in
            query.with(\.$plots)
        }
        
        guard !profile.plots.contains(where: { $0.name == shopPlot.name })
        else { throw ShopError.plotAlreadyOwned }
        
        guard profile.balance >= shopPlot.price
        else { throw ShopError.tooPoor(amountNeeded: shopPlot.price, currentBalance: profile.balance) }
        
        let plot = try Plot(name: shopPlot.name, size: shopPlot.size, ownerID: profile.requireID())
        
        let oldBalance = profile.balance
        profile.balance -= shopPlot.price
        
        try await req.db.transaction { db in
            try await plot.create(on: db)
            try await profile.update(on: db)
        }

        return PurchaseSuccessful(oldBalance: oldBalance, newBalance: profile.balance, numberOfItemsPurchased: 1, items: [plot])
    }
    
    private func purchaseSeeds(_ req: Request) async throws -> PurchaseSuccessful<Inventory.Seed> {
        let seedRequest = try? req.content.decode(SeedRequest.self)
        var seedsRequest = try? req.content.decode([SeedRequest].self)
        
        if let seedRequest {
            seedsRequest = [seedRequest]
        }
        
        guard let seedsRequest
        else { throw ShopError.invalidSeedsRequest }
        
        // Validate Seeds
        var seeds = [Shop.Seed]()
        var unknowns = [String]()
        var totalItems = 0
        
        seedsRequest.forEach { request in
            if let seed = Shop.seeds[request.name] {
                seeds.append(seed)
                totalItems += request.amount
            } else { unknowns.append(request.name) }
        }
        
        guard unknowns.isEmpty
        else { throw ShopError.unknownSeeds(name: unknowns) }
        
        let profile = try await req.getProfile() { query in
            query.with(\.$inventory)
        }
        
        guard let inventory = profile.inventory
        else { throw ServerError.unknownError }
        
        let shopValues = zip(seeds, seedsRequest)
        let cost = shopValues.reduce(into: 0, { $0 += ($1.0.price * $1.1.amount) })
        
        guard profile.balance >= cost
        else { throw ShopError.tooPoor(amountNeeded: cost, currentBalance: profile.balance) }
        
        shopValues.forEach { seed, request in
            let currentAmount = inventory.seeds.first(where: { $0.name == seed.name })?.amount ?? 0
            let newItem = Inventory.Seed(name: seed.name, amount: request.amount + currentAmount, growthDurationSeconds: seed.growthDurationSeconds)
            inventory.seeds.update(with: newItem)
        }
        
        let oldBalance = profile.balance
        profile.balance -= cost
        
        try await req.db.transaction { db in
            try await profile.update(on: db)
            try await inventory.update(on: db)
        }
        
        return PurchaseSuccessful(oldBalance: oldBalance, newBalance: profile.balance, numberOfItemsPurchased: totalItems, items: nil)
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
    
    private struct PurchaseSuccessful<Product: Content>: Content {
        let oldBalance: Int
        let newBalance: Int
        let numberOfItemsPurchased: Int
        let items: [Product]?
        
        enum CodingKeys: String, CodingKey {
            case oldBalance = "old_balance"
            case newBalance = "new_balance"
            case numberOfItemsPurchased = "number_of_items_purchased"
            case items
        }
    }
    
    private struct SeedRequest: Content {
        let name: String
        let amount: Int
    }
    
    private enum ShopError: AbortError {
        case unknownPlot
        case plotAlreadyOwned
        
        case unknownSeeds(name: [String])
        case invalidSeedsRequest
        
        case tooPoor(amountNeeded: Int, currentBalance: Int)
        
        var status: HTTPResponseStatus {
            .badRequest
        }
        
        var reason: String {
            switch self {
                case .unknownPlot: "Unknown plot provided, check the ID."
                case .plotAlreadyOwned: "You already own this plot. You can only buy each plot once."
                case .unknownSeeds(let name): "The following seed names were not recognized, please check your spelling: \(name)"
                case .invalidSeedsRequest: "Your purchase request for seeds was in an invalid format."
                case .tooPoor(let amount, let balance): "You don't have enough for this purchase. Requires: $\(amount) | Balance: $\(balance)"
            }
        }
    }
}
