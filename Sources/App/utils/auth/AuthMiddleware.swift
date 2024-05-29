//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/04/24.
//

import Fluent
import Vapor
import JWT

struct AuthMiddleware: Middleware {
    func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        do {
            let payload = try request.jwt.verify(as: JWTModel.self)
            
            return User.query(on: request.db)
                .filter(\.$access_token == request.headers.bearerAuthorization?.token ?? "")
                .first()
                .unwrap(or: AbortDefault.unauthorized )
                .flatMapThrowing { user in
                    if user.email != payload.subject.value { throw AbortDefault.unauthorized }
                    request.auth.login(user)
                    request.storage.set(UserStorage.self, to: user)
                }
                .flatMap { _ in next.respond(to: request) }
        } catch {
            return request.eventLoop.makeFailedFuture(AbortDefault.unauthorized)
        }
    }
    
    
}

struct UserStorage: StorageKey {
    typealias Value = User?
}
