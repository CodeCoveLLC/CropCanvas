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
    
    private func createProfile(_ req: Request) async throws -> TokenResponse {
        let userInfo = try req.content.decode(UserPost.self)
        
        guard try await Profile.query(on: req.db)
            .filter(\.$name == userInfo.name)
            .field(\.$name)
            .first() == nil
        else { throw ProfileError.usernameTaken }
        
        let profile = Profile(id: UUID(), name: userInfo.name, money: 1000)
        
        try await profile.create(on: req.db)
        
        return TokenResponse(token: profile.token)
    }
    
    private func getProfile(_ req: Request) async throws -> Profile {
        try await req.getProfile()
    }
    
    private struct UserPost: Content {
        let name: String
    }
    
    private struct TokenResponse: Content {
        let token: String
    }
    
    enum ProfileError: AbortError {
        case usernameTaken
        
        var reason: String {
            switch self {
                case .usernameTaken: "Username Already Taken"
            }
        }
        
        var status: HTTPResponseStatus {
            switch self {
                case .usernameTaken: .unauthorized
            }
        }
    }
}
