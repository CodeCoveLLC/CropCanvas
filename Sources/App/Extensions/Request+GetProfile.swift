//
//  Request+GetProfile.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor
import Fluent

extension Request {
    
    func getProfile() async throws -> Profile {
        let token = try getToken()
        
        guard let profile = try await Profile.query(on: self.db)
            .filter(\.$token == token)
            .first()
        else { throw ProfileTokenError.noProfileFound }
        
        return profile
    }
    
    func getProfile(with builder: (QueryBuilder<Profile>) -> QueryBuilder<Profile>) async throws -> Profile {
        let token = try getToken()
        
        guard let profile = try await builder(
            Profile.query(on: self.db)
                .filter(\.$token == token)
        ).first()
        else { throw ProfileTokenError.noProfileFound }
        
        return profile
    }
    
    private func getToken() throws -> String {
        guard let token = self.headers.bearerAuthorization?.token
        else { throw ProfileTokenError.noTokenFound }
        return token
    }
    
    enum ProfileTokenError: RespondableError {
        case noTokenFound
        case noProfileFound
        
        var response: Response {
            switch self {
                case .noTokenFound: Response(status: .unauthorized, body: "No Bearer Token Found")
                case .noProfileFound: Response(status: .unauthorized, body: "No Profile With Matching Token Found")
            }
        }
    }
}

