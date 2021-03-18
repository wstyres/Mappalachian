//
//  GeoJSONDecoder.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/23/20.
//

import Foundation
import MapKit

protocol GeoJSONDecodableFeature {
    init(feature: MKGeoJSONFeature) throws
}

class GeoJSONDecoder {
    private let geoJSONDecoder = MKGeoJSONDecoder()
    
    func decode(_ dataDirectory: URL) -> Venue? {
        // Decode all the features
        if let venue = decodeFeatures(Venue.self, in: dataDirectory).first {
            do {
                let buildingPaths = try FileManager.default.contentsOfDirectory(at: dataDirectory.appendingPathComponent("Buildings"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
                for buildingPath in buildingPaths {
                    if let building = decodeFeatures(Building.self, in: buildingPath).first {
                        building.levels = decodeFeatures(Level.self, in: buildingPath)
                        let levelsDirectory = buildingPath.appendingPathComponent("Levels")
                        for level in building.levels {
                            let filename = level.identifier.replacingOccurrences(of: building.identifier.appending("-"), with: "").appending(".geojson")
                            let levelPath = levelsDirectory.appendingPathComponent(filename)
                            let openingsPath = levelsDirectory.appendingPathComponent("Openings").appendingPathComponent(filename)
                            if FileManager.default.fileExists(atPath: levelPath.path) {
                                level.units = decodeFeatures(Unit.self, at: levelPath)
                            }
                            if FileManager.default.fileExists(atPath: openingsPath.path) {
                                level.openings = decodeFeatures(Opening.self, at: openingsPath)
                            }
                        }
                        venue.buildings.append(building)
                    }
                }
                return venue
            } catch let error {
                print("Error while getting directory contents: \(error)")
            }
        }
        
        return nil
    }
    
    private func decodeFeatures<T: GeoJSONDecodableFeature>(_ type: T.Type, in directory: URL) -> [T] {
        return decodeFeatures(type, at: directory.appendingPathComponent("\(type).geojson".lowercased()))
    }
    
    private func decodeFeatures<T: GeoJSONDecodableFeature>(_ type: T.Type, at path: URL) -> [T] {
        do {
            let data = try Data(contentsOf: path)
            let geoJSONFeatures = try geoJSONDecoder.decode(data)
            let MKFeatures = geoJSONFeatures as! [MKGeoJSONFeature]
            
            let features = try MKFeatures.map { try type.init(feature: $0) }
            return features
        } catch let error {
            print("An error occurred while decoding features: \(error.localizedDescription)")
            return []
        }
    }
}
