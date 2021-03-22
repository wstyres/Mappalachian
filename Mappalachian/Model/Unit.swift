//
//  Unit.swift
//  Mappalachian
//
//  Created by Wilson Styres on 11/5/20.
//

import Foundation
import MapKit

class Unit: Feature<Unit.Properties> {
    struct Properties: Codable {
        let category: String
        let levelId: String
    }
}

extension Unit: FeatureStyle {
    private enum Category: String {
        case concrete
        case elevator
        case stairs
        case restroom
        case restroomMale = "restroom.male"
        case restroomFemale = "restroom.female"
        case restroomUnisex = "restroom.unisex"
        case room
        case nonpublic
        case classroom
        case office
        case laboratory
        case privateLounge = "privatelounge"
        case conference
        case mechanical
        case serverroom
        case its
    }
    
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = Category(rawValue: self.properties!.category) {
            switch category {
            case .concrete:
                overlayRenderer.fillColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
            case .elevator, .stairs:
                overlayRenderer.fillColor = UIColor(red: 0.80, green: 0.86, blue: 0.90, alpha: 1.00)
            case .restroom, .restroomMale, .restroomFemale, .restroomUnisex:
                overlayRenderer.fillColor = UIColor(red: 0.91, green: 0.86, blue: 0.93, alpha: 1.00)
            case .room:
                overlayRenderer.fillColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.00)
            case .nonpublic:
                overlayRenderer.fillColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00)
            case .classroom:
                overlayRenderer.fillColor = UIColor(red: 0.97, green: 0.96, blue: 0.91, alpha: 1.00)
            case .office:
                overlayRenderer.fillColor = UIColor(red: 0.78, green: 0.92, blue: 0.79, alpha: 1.00)
            case .laboratory:
                overlayRenderer.fillColor = UIColor(red: 0.93, green: 0.95, blue: 0.89, alpha: 1.00)
            case .privateLounge:
                overlayRenderer.fillColor = UIColor(red: 1.00, green: 0.76, blue: 0.71, alpha: 1.00)
            case .conference:
                overlayRenderer.fillColor = UIColor(red: 0.68, green: 0.88, blue: 0.88, alpha: 1.00)
            case .mechanical:
                overlayRenderer.fillColor = UIColor(red: 0.83, green: 0.88, blue: 0.86, alpha: 1.00)
            case .serverroom:
                overlayRenderer.fillColor = UIColor(red: 0.92, green: 0.96, blue: 0.79, alpha: 1.00)
            case .its:
                overlayRenderer.fillColor = UIColor(red: 0.94, green: 0.78, blue: 0.90, alpha: 1.00)
            }
        } else {
            overlayRenderer.fillColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
        }

        overlayRenderer.strokeColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
        overlayRenderer.lineWidth = 1.3
    }
}
