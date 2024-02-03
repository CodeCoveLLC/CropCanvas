//
//  ProfileMigrations.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Fluent

class ProfileCreationMigration: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(Profile.schema)
            .id()
            .field(Profile.nameField, .string)
            .field(Profile.tokenField, .string)
            .field(Profile.balanceField, .int)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Profile.schema).delete()
    }
}
