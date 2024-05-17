//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent

struct BranchMigration: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(Branch.schema).delete()
    }
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(Branch.schema)
            .id()
            .field("name", .string, .required)
            .field("startTime", .datetime, .required)
            .field("endTime", .datetime, .required)
            .field("commerce_id", .uuid, .required, .references(Commerce.schema, "id", onDelete: .cascade))
            .create()
        
    }
    
    
}
