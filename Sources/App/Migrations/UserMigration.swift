//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent

struct UserMigration: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(User.schema).delete()
    }
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("last_name", .string, .required)
            .field("mother_name", .string , .required)
            .field("start_time", .datetime, .required)
            .field("end_time" , .datetime, .required)
            .field("access_token", .string)
            .field("otp_data", .dictionary)
            .field("createdAt", .datetime)
            .field("role", .string, .required)
            .field("number_phone", .string, .required)
            .field("password", .string, .required)
            .field("commerce_id", .uuid, .required, .references(Commerce.schema, "id", onDelete: .cascade, onUpdate: .cascade))
            .field("branch_id", .uuid, .references(Branch.schema, "id", onDelete: .cascade, onUpdate: .cascade))
            .unique(on: "number_phone", "email")
            .create()
    }
    
    
}
