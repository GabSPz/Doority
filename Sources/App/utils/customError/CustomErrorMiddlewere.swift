//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 01/06/24.
//

import Vapor
import Fluent

struct CustomErrorMiddleware: Middleware {
    func respond(to request: Vapor.Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapError { error in
            if let abortError = error as? AbortError {
                let modelResponse: ModelResponse<EmptyCodable> = abortError.toModelResponse()
                let response = Response(status: .custom(code: UInt(modelResponse.code), reasonPhrase: modelResponse.description), body: .init(data: try! JSONEncoder().encode(modelResponse)))
                response.headers.contentType = .json
                return request.eventLoop.makeSucceededFuture(response)
            } else {
                // Otros tipos de errores no manejados específicamente se propagan
                return request.eventLoop.makeFailedFuture(error)
            }
        }
    }
}

struct EmptyCodable: Content {}

extension AbortError {
    func toModelResponse<T: Codable>(_ model: T? = nil) -> ModelResponse<T> {
        return ModelResponse(code: Int(status.code), description: reason, body: model)
    }
}
