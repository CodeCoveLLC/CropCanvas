//
//  PlotsController.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor
import Foundation

class PlotsController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let plots = routes.grouped("plots")
        plots.get(use: getPlots)
        plots.post("plant", ":plot_id", use: plantSeeds)
        plots.post("harvest", ":plot_id", use: harvestPlot)
    }
    
    private func getPlots(_ req: Request) async throws -> [Plot] {
        let profile = try await req.getProfile { query in
            query.with(\.$plots)
        }
        
        return profile.plots
    }
    
    private func plantSeeds(_ req: Request) async throws -> Plot.Plant {
        let plotID = req.parameters.get("plot_id", as: UUID.self)
        let plantRequest = try req.content.decode(PlantRequestBody.self)
        
        let profile = try await req.getProfile { query in
            query.with(\.$plots)
                .with(\.$inventory)
        }
        
        guard let inventory = profile.inventory
        else { throw ServerError.unknownError }
        
        guard let plot = profile.plots.first(where: { $0.id == plotID })
        else { throw PlotError.invalidPlot }
        
        guard plot.plant == nil
        else { throw PlotError.plotBeingUsed }
        
        guard plot.size >= plantRequest.amount
        else { throw PlotError.tooManySeeds(plotSize: plot.size, requsted: plantRequest.amount) }
        
        guard plantRequest.amount > 0,
              let shopPlant = Shop.seeds[plantRequest.name]
        else { throw PlotError.invalidSeedRequest }
        
        let inventorySeeds = inventory.seeds.first(where: { $0.name == plantRequest.name })
        guard let inventorySeeds,
              inventorySeeds.amount >= plantRequest.amount
        else { throw PlotError.notEnoughSeeds(requested: plantRequest.amount, owned: inventorySeeds?.amount ?? 0) }
        
        plot.plant = Plot.Plant(
            name: shopPlant.name,
            amount: plantRequest.amount,
            plantedDate: .now,
            maturationDate: .now.addingTimeInterval(Double(shopPlant.growthDurationSeconds))
        )
        
        inventory.seeds.remove(inventorySeeds)
        if inventorySeeds.amount > plantRequest.amount {
            inventory.seeds.update(with: Inventory.Seed(name: inventorySeeds.name, amount: inventorySeeds.amount - plantRequest.amount, growthDurationSeconds: inventorySeeds.growthDurationSeconds))
        }
        
        try await req.db.transaction { db in
            try await inventory.update(on: db)
            try await plot.update(on: db)
        }
            
        guard let plant = plot.plant
        else { throw ServerError.unknownError }
        
        return plant
    }
    
    private func harvestPlot(_ req: Request) async throws -> Inventory.Product {
        let plotID = req.parameters.get("plot_id", as: UUID.self)
        let profile = try await req.getProfile { query in
            query.with(\.$plots)
                .with(\.$inventory)
        }
        
        guard let plot = profile.plots.first(where: { $0.id == plotID })
        else { throw PlotError.invalidPlot }
        
        guard let inventory = profile.inventory
        else { throw ServerError.unknownError }
        
        guard let plant = plot.plant
        else { throw PlotError.nothingToHarvest }
        
        guard plant.maturationDate < .now
        else { throw PlotError.plantNotMature(timeLeft: abs(Int(plant.maturationDate.timeIntervalSinceNow)))}
        
        var producedProduct = try Inventory.Product(using: plant)
        let currentProduct = inventory.products.first(where: { $0.name == plant.name })
        producedProduct.amount += currentProduct?.amount ?? 0
        inventory.products.update(with: producedProduct)
        
        plot.plant = nil
        
        try await req.db.transaction { db in
            try await plot.update(on: db)
            try await inventory.update(on: db)
        }
        
        return producedProduct
    }
    
    private struct PlantRequestBody: Content {
        let name: String
        let amount: Int
    }
    
    private enum PlotError: AbortError {
        case invalidPlot
        case plotBeingUsed
        case nothingToHarvest
        case plantNotMature(timeLeft: Int)
        case invalidSeedRequest
        case notEnoughSeeds(requested: Int, owned: Int)
        case tooManySeeds(plotSize: Int, requsted: Int)
        
        var status: HTTPResponseStatus { .badRequest }
        
        var reason: String {
            switch self {
                case .invalidPlot: "No plot found with matching ID."
                case .plotBeingUsed: "This plot is already in use."
                case .nothingToHarvest: "There is nothing to harvest from the provided plot."
                case .plantNotMature(let timeLeft): "The plant isn't old enough to harvest, it will be ready in \(timeLeft) seconds."
                case .invalidSeedRequest: "Your plant request was invalid. Check seed name spelling, and that the amount you are trying to plant is greater than 0."
                case .notEnoughSeeds(let requested, let owned): "You requested to use \(requested) seeds, you only have \(owned)"
                case .tooManySeeds(let plotSize, let requested): "Your plot can only hold \(plotSize) seeds, you requsted to use \(requested)"
            }
        }
    }
}
