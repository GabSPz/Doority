//
//  File.swift
//
//
//  Created by Gabriel Sanchez Peraza on 16/05/24.
//

import Vapor
import Fluent

struct AccessController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let accesses = routes.grouped("accesses")
        let accessAuth = accesses.grouped(AuthMiddleware())
        
        accesses.post("validate", use: validateAccess)
        accessAuth.post("add", use: addAccess)
        accessAuth.put("update", use: updateAccess)
        accessAuth.delete("delete", use: deleteAccess)
        
    }
    
    //POST accesses/validate?branch_id={}
    func validateAccess(req: Request) async throws -> ModelResponse <Bool> {
        let branch_id: UUID = try req.query.get(UUID.self, at: "branch_id")
        guard let access_value: String = try req.content.decode([String: String].self)["access_value"] else { throw AbortDefault.badRequest("No se encontrado un valor para 'access_value', valor nulo")}
        
        guard let access = try await Access.query(on: req.db)
            .filter(\.$value == access_value)
            .with(\.$user)
            .first()
        else { return .init(code: 200, description: "El valor de 'access_value' no esta registrado", body: false)}
        
        guard let branch = try await Branch.query(on: req.db)
            .filter(\.$id == branch_id)
            .with(\.$commerce, { commerce in
                commerce.with(\.$users)
            })
            .first()
        else { throw AbortDefault.idNotExist(description: branch_id.uuidString) }
        
        if !branch.commerce.users.contains(where: { $0.id == access.$user.id}) {
            //El usuario no esta dado de alta en el comercio, por lo que no puede acceder
            return .init(code: 200, description: "El usuario no esta dado de alta en el comercio", body: false)
        }
        if access.user.start_time > access.user.end_time {
            //Se expiro la membresia del usuario
            return .init(code: 200, description: "Membresía expirada", body: false)
        }
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
        let startComponents = calendar.dateComponents([.hour, .minute], from: branch.start_time)
        let endComponents = calendar.dateComponents([.hour, .minute], from: branch.end_time)
        
        let now = nowComponents.hour! * 60 + nowComponents.minute!
        let start = startComponents.hour! * 60 + startComponents.minute!
        let end = endComponents.hour! * 60 + endComponents.minute!
        
        let isOpen: Bool
        if start <= end {
            isOpen = now >= start && now <= end
        } else {
            isOpen = now >= start || now <= end
        }
        
        if isOpen {
            //Si el usuario pudo acceder, se creara un record
            let newRecord = try Record(user: access.$user.id, branch: branch_id, type: access.type, access: access.requireID())
            try await newRecord.save(on: req.db)
        }
        
        return .init(code: 200, description: "Success", body: isOpen)
    }
    
    //POST accesses/add
    func addAccess(req: Request) async throws -> ModelResponse<Access.Public> {
        let newAccess = try req.content.decode(Access.Public.self)
        
        let accessDb: Access = .init(value: newAccess.value, type: newAccess.type.rawValue, user: newAccess.user_id)
        
        try await accessDb.save(on: req.db)
        
        return try .init(code: 200, description: "Success", body: accessDb.toPublic())
        
    }
    
    //PUT accesses/update
    func updateAccess(req: Request) async throws -> ModelResponse<Access.Public> {
        let updateAccess = try req.content.decode(Access.Public.self)
        
        guard let accessDb: Access = try await Access.find(updateAccess.id, on: req.db) else { throw AbortDefault.idNotExist(description: updateAccess.id?.uuidString ?? "") }
        
        accessDb.type = updateAccess.type.rawValue
        accessDb.value = updateAccess.value
        
        try await accessDb.update(on: req.db)
        
        return try .init(code: 200, description: "Success", body: accessDb.toPublic())
    }
    
    //DELETE accesses/delete?access_id={}
    func deleteAccess(req: Request) async throws -> ModelResponse<Bool> {
        let access_id = try req.query.get(UUID.self, at: "access_id")
        
        guard let access = try await Access.find(access_id, on: req.db) else { throw AbortDefault.idNotExist(description: access_id.uuidString) }
        
        try await access.delete(on: req.db)
        
        return .init(code: 200, description: "Success", body: true)
    }
}
