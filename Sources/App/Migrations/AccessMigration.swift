//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent

struct AccessMigration: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(Access.schema).delete()
    }
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(Access.schema)
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade, onUpdate: .cascade))
            .field("type", .string, .required)
            .create()
    }
    

    
    
}
