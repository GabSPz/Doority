//
//  File.swift
//
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor

enum AbortDefault: AbortError {
    
    case relationNotFound(parent:String, child: String)
    case idNotExist
    case valueNilFromServer(key: String)
    case badRequest(String)
    var reason: String {
        switch self {
        case .relationNotFound(let parent, let child):
            return "No se ha encontrado una relación entre \(parent) y \(child)"
        case .idNotExist:
            return "No existe el objeto que se está buscando"
        case .valueNilFromServer(let key):
            return "El valor de |\(key)| es nulo, intentelo más tarde"
        case .badRequest(let reason):
            return reason
        }
    }
    var status: NIOHTTP1.HTTPResponseStatus {
        switch self {
        case .relationNotFound, .idNotExist, .valueNilFromServer:
            return .internalServerError
        case .badRequest:
            return .badRequest
        }
    }
    
}

