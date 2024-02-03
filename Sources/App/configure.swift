import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.databases.use(DatabaseConfigurationFactory.postgres(url: Environment.get("DATABASE_URL") ?? "NO DATABASE URL FOUND"), as: .psql)
    
    // MARK: Replaces Error Middleware | Could Cause Issues | Explore More
    app.middleware = .init()
    app.middleware.use(ErrorHandlingMiddleware())
    
    app.migrations.add(ProfileCreationMigration())
    app.migrations.add(PlotCreationMigration())

    // register routes
    try routes(app)
}
