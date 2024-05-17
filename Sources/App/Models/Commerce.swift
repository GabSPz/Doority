//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor
import Fluent

final class Commerce: ModelContent {
    
    static var schema: String = "commerces"
    
    public struct Public: Content {
        var id: UUID
        var name: String
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$commerce)
    var users: [User]
    
    @Children(for: \.$commerce)
    var branches: [Branch]
    
    init() {
        
    }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    func toPublic() throws -> Commerce.Public {
        let id = try id.validModel()
        return .init(id: id, name: name)
    }
    
}
