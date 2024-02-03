import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.routes.register(collection: ProfileController())
    try app.routes.register(collection: ShopController())
    try app.routes.register(collection: MarketController())
}
