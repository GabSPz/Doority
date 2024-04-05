//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor

struct RecordDTO: Content {
    var record: Record.Public
    var userName: String?
    var user_id: UUID?
    
    
}

