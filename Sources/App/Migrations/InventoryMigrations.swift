//
//  InventoryMigrations.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Foundation
import Fluent

class InventoryCreationMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Inventory.schema)
            .id()
            .field(Inventory.seedField, .array(of: .dictionary))
            .field(Inventory.productField, .array(of: .dictionary))
            .field(Inventory.ownerField, .uuid, .required, .references(Profile.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Inventory.schema).delete()
    }
}
