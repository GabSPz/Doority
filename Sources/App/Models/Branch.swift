//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor
import Fluent

final class Branch: ModelContent {
    
    static var schema: String = "branches"
    
    public struct Public: Content {
        var id: UUID
        var name: String
        var startTime: Date
        var endTime: Date
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "startTime")
    var startTime: Date
    
    @Field(key: "endTime")
    var endTime: Date
    
    @Children(for: \.$branch)
    var employees: [User]
    
    @Children(for: \.$branch)
    var records: [Record]
    
    init(id: UUID? = nil, name: String, startTime: Date, endTime: Date) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
    }
    
    init() {
        
    }
    
    func toPublic() throws -> Branch.Public {
        let id = try id.validModel()
        
        return .init(id: id, name: name, startTime: startTime, endTime: endTime)
    }
}

