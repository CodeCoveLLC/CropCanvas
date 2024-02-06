import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.routes.get { req in
        req.redirect(to: "/index.html")
    }
    try app.routes.register(collection: ProfileController())
    try app.routes.register(collection: ShopController())
    try app.routes.register(collection: MarketController())
    try app.routes.register(collection: PlotsController())
}
