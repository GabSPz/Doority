//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 04/04/24.
//

import Vapor

struct NewUserDTO: Content {
    var name: String
    var lastName: String
    var motherName: String
    var startTime: Date
    var endTime: Date
    var numberPhone: String
    var email: String
    var password: String
    var coommerceName: String
}
