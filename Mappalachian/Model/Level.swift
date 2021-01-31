//
//  Level.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation
import MapKit

class Level: Feature<Level.Properties> {
    struct Properties: Codable {
        let ordinal: Int
        let category: String
        let shortName: String
        let outdoor: Bool
        let buildingIds: [String]?
    }
    
    var units: [Unit] = []
}

extension Level: FeatureStyle {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
        if properties != nil && properties!.outdoor {
            overlayRenderer.fillColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
        } else {
            overlayRenderer.fillColor = UIColor.white
        }
        overlayRenderer.lineWidth = 2.0
    }
}
