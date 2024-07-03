//
//  File.swift
//  
//
//  Created by Lukas Simonson on 7/3/24.
//

import Fluent

extension EagerLoadBuilder {
    func with<Relation>(
        _ relationKey: KeyPath<Model, Relation>,
        when condition: Bool
    ) -> Self where Relation: EagerLoadable, Relation.From == Model
    {
        if condition {
            Relation.eagerLoad(relationKey, to: self)
        }
        
        return self
    }
}
