//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/04/24.
//

import Foundation
import JWT

struct JWTModel: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }
    
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
