import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: AuthController())
    try app.register(collection: CommerceController())
    try app.register(collection: AccessController())
    try app.register(collection: RecordController())
}
