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
        var id: UUID?
        var name: String
        var start_time: Date
        var end_time: Date
        var commerce_id: UUID?
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "startTime")
    var start_time: Date
    
    @Field(key: "endTime")
    var end_time: Date
    
    @Children(for: \.$branch)
    var employees: [User]
    
    @Children(for: \.$branch)
    var records: [Record]
    
    @Parent(key: "commerce_id")
    var commerce: Commerce
    
    init(id: UUID? = nil, name: String, start_time: Date, end_time: Date, commerce_id: Commerce.IDValue) {
        self.id = id
        self.name = name
        self.start_time = start_time
        self.end_time = end_time
        self.$commerce.id = commerce_id
    }
    
    init() {
        
    }
    
    func toPublic() throws -> Branch.Public {
        let id = try id.validModel()
        
        return .init(id: id, name: name, start_time: start_time, end_time: end_time, commerce_id: $commerce.id)
    }
}

