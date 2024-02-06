import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {     
    
    if let url = Environment.get("DATABASE_URL") {
        try app.databases.use(DatabaseConfigurationFactory.postgres(url: url), as: .psql)
    } else if let url = Environment.get("DATABASE_PRIVATE_URL") {
        var config = try SQLPostgresConfiguration(url: url)
        config.coreConfiguration.tls = .disable
        app.databases.use(DatabaseConfigurationFactory.postgres(configuration: config), as: .psql)
    }
    
    // MARK: Replaces Error Middleware | Could Cause Issues | Explore More
    app.middleware = .init()
    app.middleware.use(ErrorHandlingMiddleware())
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.migrations.add(ProfileCreationMigration())
    app.migrations.add(PlotCreationMigration())
    app.migrations.add(InventoryCreationMigration())
    
    // register routes
    try routes(app)
}

