//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Fluent
import Vapor

final class User: ModelContent {
    
    static var schema: String = "users"
    
    public struct Public: Content {
        var id: UUID
        var name: String
        var last_name: String
        var mother_name: String
        var start_time: Date
        var end_time: Date
        var role: UserRole
        var number_phone: String
        var email: String
        var coommerce_id: UUID
        var branch: ParentDataDTO?
        var accesses: [Access.Public]
        var has_account: Bool
        var last_entry: Date?
        var last_exit: Date?
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "last_name")
    var last_name: String
    
    @Field(key: "mother_name")
    var mother_name: String
    
    @Field(key: "start_time")
    var start_time: Date
    
    @Field(key: "end_time")
    var end_time: Date
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "number_phone")
    var number_phone: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "access_token")
    var access_token: String?
    
    @Field(key: "otp_data")
    var otp: OtpData?
    
    @Timestamp(key: "createdAt", on: .create)
    var created_at: Date?
    
    @Parent(key: "commerce_id")
    var commerce: Commerce
    
    @OptionalParent(key: "branch_id")
    var branch: Branch?
    
    @Children(for: \.$user)
    var accesses: [Access]
    
    @Children(for: \.$user)
    var records: [Record]
    
    ///Only possible if relations Access, Commerce and Branch has been charged into User
    func toPublic() throws -> User.Public {
        //Validating
        if let branch = branch, branch.name == nil, accesses == nil, commerce.name == nil {
            throw AbortDefault.valueNilFromServer(key: "(branch, accesses, commerce)")
        }
        
        let id = try id.validModel()
        let accesses: [Access.Public] = try accesses.map { try $0.toPublic() }
        var parentData: ParentDataDTO? {
            guard let branch = branch else { return nil }
            
            return .init(id: $branch.id!, name: branch.name)
        }
        
        return .init(id: id, name: name, last_name: last_name, mother_name: mother_name, start_time: start_time, end_time: end_time, role: .init(rawValue: role) ?? .customer, number_phone: number_phone, email: email, coommerce_id: $commerce.id, branch: parentData, accesses: accesses, has_account: !self.password.isEmpty)
    }
    
    init(id: UUID? = nil, name: String, last_name: String, mother_name: String, start_time: Date, end_time: Date, role: String, number_phone: String, email: String, password: String, access_token: String? = nil, otp: OtpData? = nil, created_at: Date? = nil, commerce: Commerce.IDValue, branch: Branch.IDValue? = nil) {
        self.id = id
        self.name = name
        self.last_name = last_name
        self.mother_name = mother_name
        self.start_time = start_time
        self.end_time = end_time
        self.role = role
        self.number_phone = number_phone
        self.email = email
        self.password = password
        self.access_token = access_token
        self.otp = otp
        self.created_at = created_at
        self.$commerce.id = commerce
        if let branch { self.$branch.id = branch }
    }
    
    init() {
        
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
