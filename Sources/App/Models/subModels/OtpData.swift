//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 04/04/24.
//

import Vapor

struct OtpData: Codable {
    var code: Int
    var createdAt: Date
    var expiresAt: Date
}
