//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/07/24.
//

import Foundation

enum OTPSubjectType: String {
    case email
    case telephone
    
    static func decodeByOTPSubject(_ subject: String) -> Self? {
        if subject.isEmail {
            return .email
        }
        
        return nil
    }
}
