//
//  Plot.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Fluent
import Vapor

final class Plot: Model, Content {
    @ID(key: .id)
    var id: UUID?
    @Field(key: nameField)
    var name: String
    @Field(key: sizeField)
    var size: Int
    
    @Field(key: plantField)
    var plant: Plant?
    
    @Parent(key: ownerField)
    var owner: Profile
    
    init() {}
    
    init(_ id: UUID? = nil, name: String, size: Int, ownerID: Profile.IDValue) {
        self.id = id
        self.name = name
        self.size = size
        self.plant = nil
        self.$owner.id = ownerID
    }
}

extension Plot {
    static let schema = "plots"
    static let nameField: FieldKey = "name"
    static let sizeField: FieldKey = "size"
    static let ownerField: FieldKey = "owner_id"
    static let plantField: FieldKey = "plant"
}

extension Plot {
    final class Plant: Content {
        let name: String
        let amount: Int
        let plantedDate: Date
        let maturationDate: Date
        
        init(name: String, amount: Int, plantedDate: Date, maturationDate: Date) {
            self.name = name
            self.amount = amount
            self.plantedDate = plantedDate
            self.maturationDate = maturationDate
        }
    }
}

extension Plot {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case size
        case plant
        case owner
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(plant, forKey: .plant)
    }
}
