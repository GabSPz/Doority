//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 17/05/24.
//

import Vapor
import Fluent

struct RecordController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        let records = routes.grouped("records").grouped(AuthMiddleware())
        records.delete("delete", use: deleteRecord)
        records.put("update", use: updateRecord)
    }
    
    //PUT records/update
    func updateRecord(req: Request) async throws -> ModelResponse<Record.Public> {
        let updateRecord = try req.content.decode(Record.Public.self)
        
        guard let record: Record = try await Record.query(on: req.db)
            .filter(\.$id == updateRecord.id)
            .with(\.$user)
            .with(\.$branch)
            .first()
        else { throw AbortDefault.idNotExist(description: updateRecord.id.uuidString) }
        
        record.access_datetime = updateRecord.access_datetime
        record.type = updateRecord.type.rawValue
        
        try await record.update(on: req.db)
        
        return try .init(code: 200, description: "Success", body: record.toPublic())
    }
    
    //DELETE records/delete?record_id={}
    func deleteRecord(req: Request) async throws -> ModelResponse<Bool> {
        let record_id: UUID = try req.query.get(UUID.self, at: "record_id")
    
        guard let record = try await Record.find(record_id, on: req.db) else { throw AbortDefault.idNotExist(description: record_id.uuidString) }
        
        try await record.delete(on: req.db)
        
        return .init(code: 200, description: "Success", body: true)
    }
}
