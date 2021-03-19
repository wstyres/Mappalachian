//
//  Opening.swift
//  Mappalachian
//
//  Created by Wilson Styres on 3/18/21.
//

import Foundation
import MapKit

class Opening: Feature<Opening.Properties> {
    struct Properties: Codable {
        let category: String
        let levelId: String
    }
}

extension Opening: FeatureStyle {
    private enum Category: String {
        case exterior = "door.exterior"
        case interior = "door.interior"
        case wall
    }
    
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = Category(rawValue: self.properties!.category) {
            switch category {
            case .exterior:
                overlayRenderer.strokeColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
            case .interior:
                overlayRenderer.strokeColor = UIColor.white
            case .wall:
                overlayRenderer.strokeColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
                overlayRenderer.lineWidth = 1.3
                return
            }
        } else {
            overlayRenderer.strokeColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
        }

        overlayRenderer.lineWidth = 2.0
    }
}
