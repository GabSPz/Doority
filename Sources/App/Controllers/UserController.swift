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
        let users = routes.grouped("users").grouped(AuthMiddleware())
        
        users.get("all", use: getAll)
        users.get("token", use: getUserByToken)
        users.put("update", use: updateUser)
        users.get("records", use: getUserRecords)

        users.put("create-account", use: createUserAccount)
        users.delete("delete", use: deleteUser)
        users.post("add", use: addUser)

    }
    
    ///PUT users/create-account?user_id={}&password={}
    func createUserAccount(req: Request) async throws -> ModelResponse<Bool> {
        let user_id: UUID = try req.query.get(UUID.self, at: "user_id")
        let password = try req.query.get(String.self, at: "password")
        
        guard let user = try await User.find(user_id, on: req.db) else { throw AbortDefault.idNotExist(description: user_id.uuidString) }
        
        let passwordCryp = try Bcrypt.hash(password, cost: 10)
        user.password = passwordCryp
        
        try await user.update(on: req.db)
        
        return .init(code: 200, description: "Success", body: true)
    }
    
    //POST users/add
    func addUser(req: Request) async throws -> ModelResponse<User.Public> {
        let newUser: NewUserDTO = try req.content.decode(NewUserDTO.self)
        
        //Getting the user who is adding the newUser for permissions
        guard let userAuth = req.storage.get(UserStorage.self)?.wrapped else { throw AbortDefault.valueNilFromServer(key: "request_storage_user") }
        
        if !newUser.role.isValid(from: .init(rawValue: userAuth.role) ?? .customer) {
            throw Abort(.unauthorized, reason: "El usuario '\(userAuth.name)' no esta autorizado para agregar un usuario de tipo '\(newUser.role.rawValue)'")
        }
        
        let user: User = .init(name: newUser.name, last_name: newUser.last_name, mother_name: newUser.mother_name, start_time: newUser.start_time, end_time: newUser.end_time, role: newUser.role.rawValue, number_phone: newUser.number_phone, email: newUser.email, password: "", commerce: newUser.coommerce_id)
        
        try await user.save(on: req.db)
        
        return try .init(code: 200, description: "Success", body: user.toPublic())
    }
    
    //GET users/records?user_id={}
    func getUserRecords(req: Request) async throws -> ModelResponse<[Record.Public]> {
        guard let userID: UUID = try req.query.get(UUID?.self, at: "user_id") else { throw AbortDefault.parameterMiss("user_id") }
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userID)
            .with(\.$records, {
                $0.with(\.$user)
                $0.with(\.$branch)
            })
            .first()
        else { throw AbortDefault.idNotExist(description: userID.uuidString) }
        
        let publicRecords: [Record.Public] = try user.records.map{ try $0.toPublic() }
        
        return .init(code: 200, description: "Success", body: publicRecords)
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
        
        return .init(code: 200, description: "Success", body: try await User.query(on: req.db).with(\.$accesses).with(\.$branch).with(\.$records).all().compactMap { try $0.toPublic() })
    }
    
    //PUT users/edit
    func updateUser(req: Request) async throws -> ModelResponse<Bool> {
        let user = try req.content.decode(User.Public.self)
        
        //Getting the user who is adding the newUser for permissions
        guard let userAuth = req.storage.get(UserStorage.self)?.wrapped else { throw AbortDefault.valueNilFromServer(key: "request_storage_user") }
        
        if !user.role.isValid(from: .init(rawValue: userAuth.role) ?? .customer) {
            throw Abort(.unauthorized, reason: "El usuario '\(userAuth.name)' no esta autorizado para actualizar un usuario de tipo '\(user.role.rawValue)'")
        }
        
        guard let userDb = try await User.find(user.id, on: req.db) else { throw AbortDefault.idNotExist(description: "El valor 'user_id' proporcionado no existe") }
        
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
        let userID = try req.query.get(UUID.self, at: "user_id")
        
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
