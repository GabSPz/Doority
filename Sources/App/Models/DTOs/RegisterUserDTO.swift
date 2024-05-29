//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 29/05/24.
//

import Vapor

struct RegisterUserDTO: Content {
    var name: String
    var last_name: String
    var mother_name: String
    var start_time: Date
    var end_time: Date
    var number_phone: String
    var email: String
    var password: String
    var coommerce_name: String
}
