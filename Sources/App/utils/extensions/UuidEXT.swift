//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Fluent

extension UUID? {
    func validModel() throws -> UUID {
        guard let id = self else { throw AbortDefault.idNotExist }
        return id
    }
}
