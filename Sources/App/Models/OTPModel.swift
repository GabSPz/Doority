//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/07/24.
//

import Vapor
import Fluent

final class OTPModel: Model, Content {
    static var schema: String = "otps"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: Int
    
    @Field(key: "subject")
    var subject: String
    
    @Field(key: "subject_type")
    var subject_type: String
    
    @Timestamp(key: "created_at", on: .create)
    var created_at: Date?
    
    @Field(key: "valid_token")
    var valid_token: String
    
    @Field(key: "type")
    var type: OTPType.RawValue
    
    init(id: UUID? = nil, value: Int, subject: String, subject_type: String, created_at: Date? = nil, valid_token: String, type: OTPType) {
        self.id = id
        self.value = value
        self.subject = subject
        self.subject_type = subject_type
        self.created_at = created_at
        self.valid_token = valid_token
        self.type = type.rawValue
    }
    
    init() {
        
    }
    
    func validUniqueThenUpdateOrSave(on db: Database) async throws {
        let otp: OTPModel? = try await OTPModel.findBySubject(self.subject, on: db)
        if let otp {
            otp.created_at = .now
            otp.value = self.value
            otp.valid_token = self.valid_token
            otp.type = self.type
            
            return try await otp.update(on: db)
        }
        
        // Self OTP not exists on db
        try await self.save(on: db)
    }
    
    static func findBySubject(_ subject: String?, on db: Database) async throws -> OTPModel? {
        guard let subject = subject else { return nil }
        return try await OTPModel.query(on: db).filter(\.$subject == subject).first()
    }
}
