//
//  Building.swift
//  Mappalachian
//
//  Created by Wilson Styres on 1/17/21.
//

import UIKit

class Building: Feature<Building.Properties> {
    struct Properties: Codable {
        let category: String
    }
    
    var levels: [Level] = []
}
