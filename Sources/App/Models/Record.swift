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
        var access_datetime: Date
        var type: AccessType
        
        
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "branch_id")
    var branch: Branch
    
    @Parent(key: "access_id")
    var access: Access
    
    @Timestamp(key: "access_datetime", on: .create)
    var access_datetime: Date?
    
    @Field(key: "type")
    var type: RecordType.RawValue
    
    init(id: UUID? = nil, user: User.IDValue, branch: Branch.IDValue, type: String, access: Access.IDValue) {
        self.id = id
        self.$user.id = user
        self.$branch.id = branch
        self.type = type
        self.$access.id = access
    }
    
    init() {
        
    }
    
    func toPublic() throws -> Record.Public {
        //Validations
        let id = try id.validModel()
        guard let accessDatetimeValidated = access_datetime else { throw AbortDefault.valueNilFromServer(key: "record_access_datetime") }
        guard let typeValidate = AccessType(rawValue: type) else { throw AbortDefault.valueNilFromServer(key: "record_type") }
        
        return .init(id: id, user: .init(id: $user.id, name: user.name), branch: .init(id: $branch.id, name: branch.name), access_datetime: accessDatetimeValidated, type: typeValidate)
    }
}
