//
//  Profile.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Vapor
import Fluent


final class Profile: Model, Content {
    @ID(key: .id)
    var id: UUID?
    @Field(key: tokenField)
    var token: String
    @Field(key: nameField)
    var name: String
    @Field(key: balanceField)
    var balance: Int
    @Children(for: \.$owner)
    var plots: [Plot]
    
    init() {}
    
    init(id: UUID, name: String, money: Int) {
        self.id = id
        self.token = id.tokenized()
        self.name = name
        self.balance = money
    }
}

extension Profile {
    static let schema = "profiles"
    static let tokenField: FieldKey = "token"
    static let nameField: FieldKey = "name"
    static let balanceField: FieldKey = "balance"
}

extension Profile {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(balance, forKey: .money)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case token
        case name
        case money
    }
}
