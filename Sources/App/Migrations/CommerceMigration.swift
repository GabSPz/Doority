//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent

struct CommerceMigration: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(Commerce.schema).delete()
    }
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(Commerce.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    
}
