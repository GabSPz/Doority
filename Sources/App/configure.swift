import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    app.migrations.add(CommerceMigration())
    app.migrations.add(BranchMigration())
    app.migrations.add(UserMigration())
    app.migrations.add(AccessMigration())
    app.migrations.add(RecordMigration())
    
    // JWT
    app.jwt.signers.use(.hs256(key: Environment.get("JWT-KEY") ?? "dev-key"))

    // register routes
    try routes(app)
}

//TypeAlias for app´s models
public typealias ModelContent = Model & Content
