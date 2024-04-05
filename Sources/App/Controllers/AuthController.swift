//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 04/04/24.
//

import Vapor

struct AuthController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        var auth = routes.grouped("auth")
        
        auth.post("register", use: registerNewUser)
    }
    
    //POST auth/register
    func registerNewUser(req: Request) async throws -> ModelResponse<String> {
        let newUser: NewUserDTO = try req.content.decode(NewUserDTO.self)
        
        try await req.db.transaction { db in
            let commerce = Commerce(name: newUser.coommerceName)
            try await commerce.save(on: db)
            
            guard let commerceID = commerce.id else { throw AbortDefault.valueNilFromServer(key: "commerce_id") }
            
            let passwordCryp = try Bcrypt.hash(newUser.password, cost: 10)
            let user = User(name: newUser.name, lastName: newUser.lastName, motherName: newUser.motherName, startTime: newUser.startTime, endTime: newUser.endTime, role: UserRole.admin.rawValue, numberPhone: newUser.numberPhone, email: newUser.email.lowercased(), password: passwordCryp, commerce: commerceID)
            
            try await user.save(on: db)
            
            
        }
        
        return .init(code: 200, description: "Success", body: "")
    }
    
}

