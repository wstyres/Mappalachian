//
//  Amenity.swift
//  Mappalachian
//
//  Created by Wilson Styres on 3/21/21.
//

import Foundation
import MapKit

class Amenity: Feature<Amenity.Properties>, MKAnnotation {
    struct Properties: Codable {
        let category: String
        let name: String?
        let units: [String]
    }
    
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var title: String?
    var subtitle: String?
}

extension Amenity: FeatureStyle {
    private enum Category: String {
        case restroom
        case stairs
        case elevator
    }
    
    func configure(annotationView: MKAnnotationView) {
        if let category = Category(rawValue: self.properties!.category) {
            switch category {
            case .restroom:
                annotationView.backgroundColor = UIColor.systemPurple
            case .elevator, .stairs:
                annotationView.backgroundColor = UIColor.systemTeal
            }
        } else {
            annotationView.backgroundColor = UIColor.systemGreen
        }
                
        annotationView.displayPriority = .defaultLow
    }
}
