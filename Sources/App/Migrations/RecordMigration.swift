//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent

struct RecordMigration: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(Record.schema).delete()
    }
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(Record.schema)
            .id()
            .field("type", .string, .required)
            .field("access_datetime", .datetime)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade, onUpdate: .cascade))
            .field("branch_id", .uuid, .required, .references(Branch.schema, "id", onDelete: .cascade, onUpdate: .cascade))
            .create()
    }
    
    
}
