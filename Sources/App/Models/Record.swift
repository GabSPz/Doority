//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor
import Fluent

final class Record: ModelContent {
    static var schema: String = "records"
    
    public struct Public: Content {
        var id: UUID
        var user: ParentDataDTO
        var branch: ParentDataDTO
        var accessDatetime: Date
        var type: AccessType.RawValue
        
        
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "branch_id")
    var branch: Branch
    
    @Timestamp(key: "access_datetime", on: .create)
    var accessDatetime: Date?
    
    @Field(key: "type")
    var type: AccessType.RawValue
    
    init(id: UUID? = nil, user: User.IDValue, branch: Branch.IDValue, accessDatetime: Date? = nil, type: String) {
        self.id = id
        self.$user.id = user
        self.$branch.id = branch
        self.accessDatetime = accessDatetime
        self.type = type
    }
    
    init() {
        
    }
    
    func toPublic() throws -> Record.Public {
        //Validations
        let id = try id.validModel()
        guard let accessDatetimeValidated = accessDatetime else { throw AbortDefault.valueNilFromServer(key: "accessDateTime") }
        
        return .init(id: id, user: .init(id: $user.id, name: user.name), branch: .init(id: $branch.id, name: branch.name), accessDatetime: accessDatetimeValidated, type: type)
    }
}
