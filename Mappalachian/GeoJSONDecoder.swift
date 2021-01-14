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
    func decode(_ dataDirectory: URL) -> Venue {
        let archive = GeoJSONArchive(directory: dataDirectory)
        
        // Decode all the features
        let venues = decodeFeatures(Venue.self, from: .venue, in: archive)
        let levels = decodeFeatures(Level.self, from: .level, in: archive)
        let units = decodeFeatures(Unit.self, from: .unit, in: archive)
        
        if venues.count != 1 {
            print("More than one venue! This is illegal!")
        }
        let venue = venues[0]
        venue.levelsByOrdinal = Dictionary(grouping: levels, by: { $0.properties!.ordinal })
        
        let unitsByLevel = Dictionary(grouping: units, by: { $0.properties?.levelId })
        for level in levels {
            if let unitsInLevel = unitsByLevel[level.identifier] {
                level.units = unitsInLevel
            }
        }
        
        return venue
    }
    
    private func decodeFeatures<T: GeoJSONDecodableFeature>(_ type: T.Type, from file: GeoJSONArchive.File, in archive: GeoJSONArchive) -> [T] {
        let fileURL = archive.fileURL(for: file)
        do {
            let data = try Data(contentsOf: fileURL)
            let geoJSONFeatures = try geoJSONDecoder.decode(data)
            let features = geoJSONFeatures as! [MKGeoJSONFeature]
            
            let imdfFeatures = try features.map { try type.init(feature: $0) }
            return imdfFeatures
        } catch {
            print("An error occurred!")
            return []
        }
    }
}
