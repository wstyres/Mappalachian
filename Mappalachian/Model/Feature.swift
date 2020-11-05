//
//  Feature.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation
import MapKit

class Feature<Properties: Decodable>: NSObject, GeoJSONDecodableFeature {
    let identifier: UUID
    var properties: Properties? = nil
    let geometry: [MKShape & MKGeoJSONObject]
    
    required init(feature: MKGeoJSONFeature) {
        let uuidString = feature.identifier!
        
        if let identifier = UUID(uuidString: uuidString) {
            self.identifier = identifier
        } else {
            self.identifier = UUID(uuidString: "invalid")!
            print("Invalid data!")
        }
        
        if let propertiesData = feature.properties {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                properties = try decoder.decode(Properties.self, from: propertiesData)
            } catch {
                print("error decoding properties!")
            }
        } else {
            print("Invalid data!")
        }
        
        self.geometry = feature.geometry
        
        super.init()
    }
}
