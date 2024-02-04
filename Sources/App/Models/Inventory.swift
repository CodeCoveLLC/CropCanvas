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
    
    @Parent(key: ownerField)
    var owner: Profile
    
    init() {}
    
    init(id: UUID? = nil, seeds: Set<Seed> = [], ownerID: Profile.IDValue) {
        self.id = id
        self.seeds = seeds
        self.$owner.id = ownerID
    }
}

extension Inventory {
    static let schema = "inventories"
    static let seedField: FieldKey = "seed"
    static let ownerField: FieldKey = "owner_id"
}

extension Inventory {
    struct Seed: Content, Hashable {
        let name: String
        let amount: Int
        let growthDurationSeconds: Int
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
    }
}

extension Inventory {
    enum CodingKeys: String, CodingKey {
        case id
        case seeds
        case owner
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(seeds, forKey: .seeds)
    }
}
