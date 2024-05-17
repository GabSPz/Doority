//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 04/04/24.
//

import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        auth.post("register", use: registerNewUser)
        auth.post("login", use: login)
    }
    
    //POST auth/register
    func registerNewUser(req: Request) async throws -> ModelResponse<String> {
        let newUser: NewUserDTO = try req.content.decode(NewUserDTO.self)
        
        let token = try await req.db.transaction { db -> String in
            let commerce = Commerce(name: newUser.coommerce_name)
            try await commerce.save(on: db)
            
            guard let commerceID = commerce.id else { throw AbortDefault.valueNilFromServer(key: "commerce_id") }
            
            let passwordCryp = try Bcrypt.hash(newUser.password, cost: 10)
            let user = User(name: newUser.name, last_name: newUser.last_name, mother_name: newUser.mother_name, start_time: newUser.start_time, end_time: newUser.end_time, role: UserRole.admin.rawValue, number_phone: newUser.number_phone, email: newUser.email.lowercased(), password: passwordCryp, commerce: commerceID)
            
            let token = try await user.generateJWTToken(on: req)
            user.access_token = token
            try await user.save(on: db)
            
            return token;
        }
        
        return .init(code: 200, description: "Success", body: token)
    }
    
    //POST auth/login
    func login(req: Request) async throws -> ModelResponse<String> {
        let loginModel = try req.content.decode(LoginDTO.self)
                
        guard let user = try await User.find(email: loginModel.email.lowercased(), on: req.db) else { throw AbortDefault.unauthorized }
        if try !user.verify(password: loginModel.password) { throw AbortDefault.unauthorized }
        
        let newToken = try await user.generateJWTToken(on: req)
        user.access_token = newToken
        try await user.update(on: req.db)
        
        return .init(code: 200, description: "Success", body: newToken);
    }

}

