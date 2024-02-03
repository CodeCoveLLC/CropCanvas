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
    @Parent(key: ownerField)
    var owner: Profile
    
    init() {}
    
    init(_ id: UUID? = nil, name: String, size: Int, ownerID: Profile.IDValue) {
        self.id = id
        self.name = name
        self.size = size
        self.$owner.id = ownerID
    }
}

extension Plot {
    static let schema = "plots"
    static let nameField: FieldKey = "name"
    static let sizeField: FieldKey = "size"
    static let ownerField: FieldKey = "owner_id"
}
