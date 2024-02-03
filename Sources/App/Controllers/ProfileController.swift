//
//  ProfileController.swift
//  
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor
import Fluent

class ProfileController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let profile = routes.grouped("profile")
        profile.get(use: getProfile)
        profile.post(use: createProfile)
    }
    
    func createProfile(_ req: Request) async throws -> Response {
        let userInfo = try req.content.decode(UserPost.self)
        
        guard try await Profile.query(on: req.db)
            .filter(\.$name == userInfo.name)
            .field(\.$name)
            .first() == nil
        else { throw ProfileError.usernameTaken }
        
        let profile = Profile(id: UUID(), name: userInfo.name, money: 1000)
        
        try await profile.create(on: req.db)
        
        return try await TokenResponse(token: profile.token).encodeResponse(for: req)
    }
    
    func getProfile(_ req: Request) async throws -> Response {
        let profile = try await req.getProfile()
        return try await profile.encodeResponse(for: req)
    }
    
    private struct UserPost: Content {
        let name: String
    }
    
    private struct TokenResponse: Content {
        let token: String
    }
    
    enum ProfileError: RespondableError {
        case usernameTaken
        
        var response: Response {
            switch self {
                case .usernameTaken: Response(status: .forbidden, body: "Username Already Taken")
            }
        }
    }
}
