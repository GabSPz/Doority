//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Fluent
import Vapor

extension User {
    
    func generateJWTToken(on req: Request) async throws -> String {
        // El token tiene 20 horas de expiracion
        let payload = JWTModel(subject: .init(value: self.email), expiration: .init(value: .now + 72000))
        
        return try req.jwt.sign(payload)
    }
    
    
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
    
    static func find(_ token: String, on db: Database) async throws -> User? {
        return try await User.query(on: db)
            .filter(\.$access_token == token)
            .with(\.$accesses)
            .with(\.$branch)
            .with(\.$records)
            .first()
    }
    
    static func find(email: String, on db: Database) async throws -> User? {
        return try await User.query(on: db)
            .filter(\.$email == email)
            .first()
    }
}
