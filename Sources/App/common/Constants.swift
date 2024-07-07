//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/07/24.
//

import Vapor

class Constants {
    private init() {}
    
    static var tokenManagerKey: String? = Environment.get("TOKEN_MANAGER_KEY")
    static var jwtKey: String = Environment.get("JWT-KEY") ?? "dev"
    
}
