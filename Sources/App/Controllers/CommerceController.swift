//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/04/24.
//

import Vapor
import Fluent

struct CommerceController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let commerces = routes.grouped("commerces").grouped(AuthMiddleware())
        
        commerces.group(":commerceID") { commerce in
            commerce.put("update", use: updateCommerce)
            commerce.group("branches") { branches in
                branches.post("add", use: addBranch)
                branches.get("all",use: getAllBranchesFromCommerce)
                branches.get(use: getBranch)
                branches.put("update", use: updateBranch)
                branches.delete("delete", use: deleteBranch)
            }
            commerce.delete("delete", use: deleteCommerce)
            commerce.get(use: getCommerce)
        }
    }
    
    //GET commerces/:commerceID
    func getCommerce(req: Request) async throws -> ModelResponse<Commerce.Public> {
        guard let commerceID = req.parameters.get("commerceID", as: UUID.self) else { throw AbortDefault.parameterMiss("commerceID") }
        
        guard let commerce: Commerce = try await Commerce.find(commerceID, on: req.db) else {
            throw AbortDefault.idNotExist(description: commerceID.uuidString)
        }
        
        return try .init(code: 200, description: "Success", body: commerce.toPublic())
    }
    
    //PUT :commerceID/update
    func updateCommerce(req: Request) async throws -> ModelResponse <Commerce.Public> {
        let updateCommcerce = try req.content.decode(Commerce.Public.self)
        
        guard let commecerceDB = try await Commerce.find(updateCommcerce.id, on: req.db) else { throw AbortDefault.idNotExist(description: updateCommcerce.id.uuidString) }
        
        commecerceDB.name = updateCommcerce.name
        
        try await commecerceDB.update(on: req.db)
        
        return try .init(code: 200, description: "Success", body: commecerceDB.toPublic())
    }
    
    //GET :commerceID/branches/all
    func getAllBranchesFromCommerce(req: Request) async throws -> ModelResponse<[Branch.Public]> {
        guard let commerceID = req.parameters.get("commerceID", as: UUID.self) else { throw AbortDefault.parameterMiss("commerceID") }
        
        guard let commerce = try await Commerce.query(on: req.db)
            .filter(\.$id == commerceID)
            .with(\.$branches)
            .first()
        else { throw AbortDefault.idNotExist(description: commerceID.uuidString) }
        
        let branchesPublic = try commerce.branches.compactMap { branch in
            return try branch.toPublic()
        }
        
        return.init(code: 200, description: "Success", body: branchesPublic)
    }
    
    //GET :commerceID/branches?branch_id
    func getBranch(req: Request) async throws -> ModelResponse<Branch.Public> {
        guard let branch_id: UUID = try req.query.get(UUID?.self, at: "branch_id") else { throw AbortDefault.parameterMiss("branch_id") }
        
        guard let branch = try await Branch.find(branch_id, on: req.db) else { throw  AbortDefault.idNotExist(description: branch_id.uuidString)}
        
        return try .init(code: 200, description: "Success", body: branch.toPublic())
    }
    
    //POST :commerceID/branches/add
    func addBranch(req: Request) async throws -> ModelResponse<Branch.Public> {
        let branchPublic = try req.content.decode(Branch.Public.self)
        guard let commerceID = req.parameters.get("commerceID", as: UUID.self) else { throw AbortDefault.parameterMiss("commerceID") }

        let newBranch: Branch = .init(name: branchPublic.name, start_time: branchPublic.start_time, end_time: branchPublic.end_time, commerce_id: commerceID)
        
        try await newBranch.save(on: req.db)
        
        return try .init(code: 200, description: "Success", body: newBranch.toPublic())
    }
    
    //PUT :commerceID/branches/update
    func updateBranch(req: Request) async throws -> ModelResponse<Branch.Public> {
        let updateBranch = try req.content.decode(Branch.Public.self)
        
        guard let branchDB = try await Branch.find(updateBranch.id, on: req.db) else { throw AbortDefault.idNotExist(description: updateBranch.id?.description ?? "invalid") }
        
        branchDB.name = updateBranch.name
        branchDB.start_time = updateBranch.start_time
        branchDB.end_time = updateBranch.end_time
        
        try await branchDB.update(on: req.db)
        
        return try .init(code: 200, description: "Success", body: branchDB.toPublic() )
    }
    
    //DELETE :commerceID/branches/delete?branch_id
    func deleteBranch(req: Request) async throws -> ModelResponse<Bool> {
        guard let branch_id: UUID = try req.query.get(UUID?.self, at: "branch_id") else { throw AbortDefault.parameterMiss("branch_id") }
        
        guard let branch = try await Branch.find(branch_id, on: req.db) else { throw  AbortDefault.idNotExist(description: branch_id.uuidString)}
        
        try await branch.delete(on: req.db)
        
        return .init(code: 200, description: "Success", body: true)
    }
    
    //DELETE :commerceID/delete
    func deleteCommerce(req: Request) async throws -> ModelResponse<Bool> {
        guard let commerceID = req.parameters.get("commerceID", as: UUID.self) else { throw AbortDefault.parameterMiss("commerceID") }
        
        guard let commerce = try await Commerce.find(commerceID, on: req.db) else { throw AbortDefault.idNotExist(description: commerceID.uuidString) }
        
        try await commerce.delete(on: req.db)
        
        return .init(code: 200, description: "Success", body: true)
    }
}
