//
//  Building.swift
//  Mappalachian
//
//  Created by Wilson Styres on 1/17/21.
//

import UIKit
import MapKit

class Building: Feature<Building.Properties> {
    struct Properties: Codable {
        let category: String
        let name: String
    }
    
    var levels: [Level] = []
    var renderedOverlays: [MKOverlay]?
}
