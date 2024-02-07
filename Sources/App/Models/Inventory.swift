//
//  File.swift
//  
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor
import Fluent

final class Inventory: Model, Content {
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: seedField)
    var seeds: Set<Seed>
    
    @Field(key: productField)
    var products: Set<Product>
    
    @Parent(key: ownerField)
    var owner: Profile
    
    init() {}
    
    init(id: UUID? = nil, seeds: Set<Seed> = [], products: Set<Product> = [], ownerID: Profile.IDValue) {
        self.id = id
        self.seeds = seeds
        self.products = products
        self.$owner.id = ownerID
    }
}

extension Inventory {
    static let schema = "inventories"
    static let seedField: FieldKey = "seeds"
    static let productField: FieldKey = "products"
    static let ownerField: FieldKey = "owner_id"
}

extension Inventory {
    struct Seed: Content, Hashable, Equatable {
        let name: String
        let amount: Int
        let growthDurationSeconds: Int
        
        var hashValue: Int {
            var hasher = Hasher()
            hasher.combine(name)
            return hasher.finalize()
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        static func ==(_ lhs: Seed, _ rhs: Seed) -> Bool {
            return lhs.name == rhs.name
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case amount
            case growthDurationSeconds = "growth_duration_seconds"
        }
    }
    
    struct Product: Content, Hashable {
        let name: String
        var amount: Int
        let baseWorth: Int
        
        init(using plant: Plot.Plant) throws {
            self.amount = plant.amount
            switch plant.name {
                case "Pomegranate Seeds":
                    self.name = "Pomegranates"
                    self.baseWorth = 105
                case "Potato Seeds":
                    self.name = "Potatoes"
                    self.baseWorth = 145
                case "Pepper Seeds":
                    self.name = "Peppers"
                    self.baseWorth = 175
                case "Cauliflower Seeds":
                    self.name = "Cauliflower"
                    self.baseWorth = 210
                case "Pumpkin Seeds":
                    self.name = "Pumpkins"
                    self.baseWorth = 240
                case "Carrot Seeds":
                    self.name = "Carrots"
                    self.baseWorth = 275
                case "Wheat Seeds":
                    self.name = "Wheat"
                    self.baseWorth = 315
                case "Blueberry Seeds":
                    self.name = "Blueberries"
                    self.baseWorth = 400
                case "Melon Seeds":
                    self.name = "Melons"
                    self.baseWorth = 495
                case "Corn Seeds":
                    self.name = "Corn"
                    self.baseWorth = 600
                default:
                    throw ServerError.unknownError
            }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case amount
            case baseWorth = "base_worth"
        }
    }
}

extension Inventory {
    enum CodingKeys: String, CodingKey {
        case id
        case seeds
        case products
        case owner
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(seeds, forKey: .seeds)
        try container.encode(products, forKey: .products)
    }
}
