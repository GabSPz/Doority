//
//  File.swift
//
//
//  Created by Gabriel Sanchez Peraza on 01/04/24.
//

import Vapor

enum AbortDefault: AbortError {
    
    case relationNotFound(parent:String, child: String)
    case idNotExist(description: String = "")
    case valueNilFromServer(key: String)
    case badRequest(String)
    case parameterMiss(String)
    case unauthorized
    case otpExpired
    var reason: String {
        switch self {
        case .relationNotFound(let parent, let child):
            return "No se ha encontrado una relación entre \(parent) y \(child)"
        case .idNotExist(let description):
            return description.isEmpty ? "No existe el objeto que se está buscando" : "No existe el objeto: '\(description)'"
        case .valueNilFromServer(let key):
            return "El valor de '\(key)' es nulo, intentelo más tarde"
        case .badRequest(let reason):
            return reason
        case .unauthorized:
            return "Credenciales no válidas"
        case .parameterMiss(let parameterDescription):
            return "EL parametro '\(parameterDescription)' no se encuentra en la peticion"
        case .otpExpired:
            return "El otp ha caducado"
        }
    }
    var status: NIOHTTP1.HTTPResponseStatus {
        switch self {
        case .relationNotFound, .idNotExist, .valueNilFromServer:
            return .internalServerError
        case .badRequest, .parameterMiss:
            return .badRequest
        case .unauthorized, .otpExpired:
            return .unauthorized
        }
    }
    
}

