//
//  Level.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation

class Level: Feature<Level.Properties> {
    struct Properties: Codable {
        let ordinal: Int
        let category: String
        let shortName: String
        let outdoor: Bool
        let buildingIds: [String]?
    }
}
