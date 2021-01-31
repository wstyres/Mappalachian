//
//  Feature.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation
import MapKit

class Feature<Properties: Decodable>: NSObject, GeoJSONDecodableFeature {
    let identifier: String
    var properties: Properties? = nil
    let geometry: [MKShape & MKGeoJSONObject]
    
    required init(feature: MKGeoJSONFeature) {
        self.identifier = feature.identifier!
        
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

protocol FeatureStyle {
    var geometry: [MKShape & MKGeoJSONObject] { get }
    func configure(overlayRenderer: MKOverlayPathRenderer)
    func configure(annotationView: MKAnnotationView)
}

extension FeatureStyle {
    func configure(overlayRenderer: MKOverlayPathRenderer) {}
    func configure(annotationView: MKAnnotationView) {}
}
