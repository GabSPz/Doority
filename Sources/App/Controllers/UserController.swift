//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Vapor
import Fluent
import JWT
struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get("all", use: getAll)
        users.get("token", use: getUserByToken)
        users.put("update", use: updateUser)
        users.group(":user_id") { user in
            user.delete(use: deleteUser)
        }
        
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
    
    //PUT users/edit
    func updateUser(req: Request) async throws -> ModelResponse<Bool> {
        let user = try req.content.decode(User.Public.self)
        
        guard let userDb = try await User.find(user.id, on: req.db) else { throw AbortDefault.idNotExist(description: "El valor user_id proporcionado no existe") }
        
        userDb.name = user.name
        userDb.last_name = user.last_name
        userDb.mother_name = user.mother_name
        userDb.role = user.role.rawValue
        userDb.number_phone = userDb.number_phone
        userDb.end_time = user.end_time
        userDb.start_time = user.start_time
        
        try await userDb.update(on: req.db)
        
        return .init(code: 200, description: "Success")
    }
    
    //DELETE users/:user_id
    func deleteUser(req: Request) async throws -> ModelResponse<Bool> {
        let userID = req.parameters.get("user_id", as: UUID.self)
        
        guard let userDb = try await User.find(userID, on: req.db) else { throw AbortDefault.idNotExist(description: "El valor user_id proporcionado no existe") }
        
        try await userDb.delete(on: req.db)
        
        return .init(code: 200, description: "Success")
    }
    
    //GET users/token
    func getUserByToken(req: Request) async throws -> ModelResponse<User.Public> {
        guard let token = req.headers.bearerAuthorization?.token else { throw AbortDefault.unauthorized }
        
        guard let user = try await User.find(token, on: req.db)?.toPublic() else { throw AbortDefault.unauthorized }

        return .init(code: 200, description: "Success", body: user)
    }
    
    
    
}
