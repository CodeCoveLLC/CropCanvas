//
//  PlotsController.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor


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
    
    private func plantSeeds(_ req: Request) async throws -> Response {
        return Response(status: .notImplemented)
    }
    
    private func harvestPlot(_ req: Request) async throws -> Response {
        return Response(status: .notImplemented)
    }
    
    private struct PlantRequestBody: Content {
        let name: String
        let amount: Int
    }
}
