//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Fluent
import Vapor

final class Access: ModelContent {
    
    static var schema: String = "accesses"
    
    public struct Public: Content {
        var id: UUID
        var value: String
        var type: AccessType.RawValue
        var user_id: UUID
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "type")
    var type: AccessType.RawValue
    
    @Parent(key: "user_id")
    var user: User
    
    init(id: UUID? = nil, value: String, type: String, user: User.IDValue) {
        self.id = id
        self.value = value
        self.type = type
        self.$user.id = user
    }
    
    init() {
        
    }
    
    func toPublic() throws -> Access.Public {
        let id = try id.validModel()
        return .init(id: id, value: value, type: type, user_id: $user.id)
    }
}
