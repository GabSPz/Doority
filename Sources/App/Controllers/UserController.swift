//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        var users = routes.grouped("users")
        
        users.get("all", use: getAll)
        
    }
    
    
    //GET users/all?commerce_id={}&branch_id={}&role={[]}
    func getAll(req: Request) async throws -> ModelResponse<[User.Public]> {
        let rolesString: [String]? = try? req.query.get([String]?.self, at: "role")
        let commerceID : UUID? = try? req.query.get(UUID?.self, at: "commerce_id")
        let branchID : UUID? = try? req.query.get(UUID?.self, at: "branch_id")

        let rolesRaw = rolesString != nil ? UserRole.parseToUserRole(with: rolesString!).compactMap { $0.rawValue } : UserRole.allCasesRawValue
        
        if let commerceID {
            let users =  try await User.getAllByCommerce(on: req.db, with: commerceID, filteredWith: rolesRaw)
            return .init(code: 200, description: "Success", body: users)
        }
        
        if let branchID {
            let users =  try await User.getAllByBranch(on: req.db, with: branchID, filteredWith: rolesRaw)
            return .init(code: 200, description: "Success", body: users)
        }
        
        throw AbortDefault.badRequest("Parametros inválidos")
    }
    
    
    
}
