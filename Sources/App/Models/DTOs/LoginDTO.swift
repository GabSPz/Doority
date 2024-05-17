//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 13/05/24.
//

import Vapor

struct LoginDTO: Content {
    var email: String
    var password: String
}
