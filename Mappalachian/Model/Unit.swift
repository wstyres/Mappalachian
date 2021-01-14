//
//  Unit.swift
//  Mappalachian
//
//  Created by Wilson Styres on 11/5/20.
//

import Foundation

class Unit: Feature<Unit.Properties> {
    struct Properties: Codable {
        let category: String
        let levelId: UUID
    }
}
