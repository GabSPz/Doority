//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 03/04/24.
//

import Vapor

struct ModelResponse<T: Content>: Content {
    var code: Int
    var description: String
    var body: T?
}
