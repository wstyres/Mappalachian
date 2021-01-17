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

private struct GeoJSONArchive {
    let baseDirectory: URL
    init(directory: URL) {
        baseDirectory = directory
    }
    
    enum File {
        case address
        case amenity
        case anchor
        case building
        case detail
        case fixture
        case footprint
        case geofence
        case kiosk
        case level
        case manifest
        case occupant
        case opening
        case relationship
        case section
        case unit
        case venue
        
        var filename: String {
            return "\(self).geojson"
        }
    }
    
    func fileURL(for file: File) -> URL {
        return baseDirectory.appendingPathComponent(file.filename)
    }
}

class GeoJSONDecoder {
    private let geoJSONDecoder = MKGeoJSONDecoder()
    func decode(_ dataDirectory: URL) -> Venue? {
        let archive = GeoJSONArchive(directory: dataDirectory)
        
        // Decode all the features
        if let venue = decodeFeatures(Venue.self, from: .venue, in: archive).first {
            do {
                let buildingPaths = try FileManager.default.contentsOfDirectory(at: dataDirectory.appendingPathComponent("Buildings"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
                for buildingPath in buildingPaths {
                    let buildingArchive = GeoJSONArchive(directory: buildingPath)
                    if let building = decodeFeatures(Building.self, from: .building, in: buildingArchive).first {
                        building.levels = decodeFeatures(Level.self, from: .level, in: buildingArchive)
                        for level in building.levels {
                            level.units = decodeFeatures(Unit.self, from: .unit, in: buildingArchive)
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
    
    private func decodeFeatures<T: GeoJSONDecodableFeature>(_ type: T.Type, from file: GeoJSONArchive.File, in archive: GeoJSONArchive) -> [T] {
        let fileURL = archive.fileURL(for: file)
        do {
            let data = try Data(contentsOf: fileURL)
            let geoJSONFeatures = try geoJSONDecoder.decode(data)
            let features = geoJSONFeatures as! [MKGeoJSONFeature]
            
            let imdfFeatures = try features.map { try type.init(feature: $0) }
            return imdfFeatures
        } catch let error {
            print("An error occurred while decoding features: \(error.localizedDescription)")
            return []
        }
    }
}
