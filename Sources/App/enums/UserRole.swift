//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor

enum UserRole: String, CaseIterable, Content {
    case admin
    case manager
    case customer
    case staff
    
    static var allCasesRawValue: [UserRole.RawValue] {
        return UserRole.allCases.map { $0.rawValue }
    }
    
    static func parseToUserRole(with list: [String]) -> [UserRole] {
        return list.compactMap { UserRole(rawValue: $0) }
    }
}

