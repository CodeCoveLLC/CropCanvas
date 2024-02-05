//
//  PlotMigrations.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Fluent

class PlotCreationMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Plot.schema)
            .id()
            .field(Plot.nameField, .string)
            .field(Plot.sizeField, .int)
            .field(Plot.plantField, .dictionary)
            .field(Plot.ownerField, .uuid, .required, .references(Profile.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Plot.schema).delete()
    }
}
