//
//  Venue.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation
import MapKit

class Venue: Feature<Venue.Properties> {
    struct Properties: Codable {
        let category: String
        let name: String
    }
    
    var buildings: [Building] = []
    
    func featureForShape(_ overlay: MKOverlay, on level: Int) -> FeatureStyle? {
        if let building = buildings.first(where: { $0.renderedOverlays!.contains(where: { $0.isEqual(overlay) }) }) {
            if let currentLevel = level < building.levels.count ? building.levels[level] : building.levels.last, let shape = overlay as? (MKShape & MKGeoJSONObject) {
                if currentLevel.geometry.contains(where: { $0 == shape } ) {
                    return currentLevel
                } else if let unit = currentLevel.units.first(where: { $0.geometry.contains(where: { $0 == shape }) }) {
                    return unit
                } else if let opening = currentLevel.openings.first(where: { $0.geometry.contains(where: { $0 == shape }) }) {
                    return opening
                }
                
                for i in 0...level {
                    let lesserLevel = building.levels[i]
                    if lesserLevel.geometry.contains(where: { $0 == shape } ) {
                        return lesserLevel
                    }
                }
            }
        }

        return nil
    }
}
