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
    
    ///Validating if the userAuthenticated has permission to add a new user
    func isValid(from userAuth: UserRole) -> Bool {
        switch self {
        case .admin:
            return userAuth == .admin
        case .manager, .staff:
            return userAuth == .admin || userAuth == .manager
        case .customer:
            return userAuth != .customer
        }
    }
}

