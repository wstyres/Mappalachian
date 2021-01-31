//
//  Venue.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation

class Venue: Feature<Venue.Properties> {
    struct Properties: Codable {
        let category: String
        let name: String
    }
    
    var buildings: [Building] = []
}
