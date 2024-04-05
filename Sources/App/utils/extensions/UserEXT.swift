//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent


extension User {
    
    static func getAllByCommerce(on db: Database, with commerceID: UUID, filteredWith roles: [UserRole.RawValue]) async throws -> [User.Public] {
        
        return try await User.query(on: db)
            .filter(\.$commerce.$id == commerceID)
            .filter(\.$role ~~ roles)
            .with(\.$accesses)
            .with(\.$branch)
            .with(\.$records)
            .all()
            .compactMap { user in
                try user.toPublic()
            }
    }
    
    static func getAllByBranch(on db: Database, with branchID: UUID, filteredWith roles: [UserRole.RawValue]) async throws -> [User.Public] {
        
        return try await User.query(on: db)
            .filter(\.$branch.$id == branchID)
            .filter(\.$role ~~ roles)
            .all()
            .compactMap { user in
                try user.toPublic()
            }
    }
}
