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
        
        
    }
    
    //GET accesses/validate?branch_id={}?access_id={}
    func validateAccess(req: Request) async throws -> ModelResponse <Bool> {
        let branch_id: UUID = try req.query.get(UUID.self, at: "branch_id")
        let access_id: UUID = try req.query.get(UUID.self, at: "access_id")
        
        guard let access = try await Access.find(access_id, on: req.db) else { throw AbortDefault.idNotExist(description: access_id.uuidString)}
        
        guard let branch = try await Branch.query(on: req.db)
            .filter(\.$id == branch_id)
            .with(\.$commerce, { commerce in
                commerce.with(\.$users)
            })
            .first()
        else { throw AbortDefault.idNotExist(description: branch_id.uuidString) }
        
        if !branch.commerce.users.contains(where: { $0.id == access.$user.id}) {
            //El usuario no esta dado de alta en el comercio, por lo que no puede acceder
            return .init(code: 200, description: "Succes", body: false)
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
            let newRecord = Record(user: access.$user.id, branch: branch_id, type: access.type, access: access_id)
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
}
