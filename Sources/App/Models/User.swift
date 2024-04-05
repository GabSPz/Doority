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
        var lastName: String
        var motherName: String
        var startTime: Date
        var endTime: Date
        var role: UserRole
        var numberPhone: String
        var email: String
        var coommerce_id: UUID
        var branch: ParentDataDTO?
        var accesses: [Access.Public]
        var hasAccount: Bool
        var lastEntry: Date?
        var lastExit: Date?
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "mother_name")
    var motherName: String
    
    @Field(key: "start_time")
    var startTime: Date
    
    @Field(key: "end_time")
    var endTime: Date
    
    @Field(key: "role")
    var role: String
    
    @Field(key: "number_phone")
    var numberPhone: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "access_token")
    var accessToken: String?
    
    @Field(key: "otp_data")
    var otp: OtpData?
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
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
        
        return .init(id: id, name: name, lastName: lastName, motherName: motherName, startTime: startTime, endTime: endTime, role: .init(rawValue: role) ?? .customer, numberPhone: numberPhone, email: email, coommerce_id: $commerce.id, branch: parentData, accesses: accesses, hasAccount: !self.password.isEmpty)
    }
    
    init(id: UUID? = nil, name: String, lastName: String, motherName: String, startTime: Date, endTime: Date, role: String, numberPhone: String, email: String, password: String, createdAt: Date? = nil, commerce: Commerce.IDValue, branch: Branch.IDValue? = nil) {
        self.id = id
        self.name = name
        self.lastName = lastName
        self.motherName = motherName
        self.startTime = startTime
        self.endTime = endTime
        self.role = role
        self.numberPhone = numberPhone
        self.email = email
        self.password = password
        self.createdAt = createdAt
        self.$commerce.id = commerce
        if let branch { self.$branch.id = branch }
    }
    
    init() {
        
    }
    
}
