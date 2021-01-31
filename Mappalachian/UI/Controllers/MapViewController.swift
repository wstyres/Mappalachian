//
//  MapViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/20/20.
//

import CoreData
import UIKit
import MapKit
import CoreLocation

protocol FeatureStyle {
    var geometry: [MKShape & MKGeoJSONObject] { get }
    func configure(overlayRenderer: MKOverlayPathRenderer)
    func configure(annotationView: MKAnnotationView)
}

extension FeatureStyle {
    func configure(overlayRenderer: MKOverlayPathRenderer) {}
    func configure(annotationView: MKAnnotationView) {}
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

extension Unit: FeatureStyle {
    private enum Category: String {
        case concrete
        case elevator
        case escalator
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
    }
    
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = Category(rawValue: self.properties!.category) {
            switch category {
            case .concrete:
                overlayRenderer.fillColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
            case .elevator, .escalator, .stairs:
                overlayRenderer.fillColor = UIColor(red: 0.80, green: 0.86, blue: 0.90, alpha: 1.00)
            case .restroom, .restroomMale, .restroomFemale, .restroomUnisex:
                overlayRenderer.fillColor = UIColor(red: 0.91, green: 0.86, blue: 0.93, alpha: 1.00)
            case .room:
                overlayRenderer.fillColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.00)
            case .nonpublic:
                overlayRenderer.fillColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00)
            case .classroom:
                overlayRenderer.fillColor = UIColor(red: 0.94, green: 0.89, blue: 0.82, alpha: 1.00)
            case .office:
                overlayRenderer.fillColor = UIColor(red: 0.78, green: 0.92, blue: 0.79, alpha: 1.00)
            case .laboratory:
                overlayRenderer.fillColor = UIColor(red: 0.91, green: 0.91, blue: 0.63, alpha: 1.00)
            case .privateLounge:
                overlayRenderer.fillColor = UIColor(red: 1.00, green: 0.76, blue: 0.71, alpha: 1.00)
            }
        } else {
            overlayRenderer.fillColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
        }

        overlayRenderer.strokeColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
        overlayRenderer.lineWidth = 1.3
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    var locationManager = CLLocationManager()
    
    var venue: Venue?
    var currentLevelFeatures = [String: [FeatureStyle]]()
    var currentLevelOverlays = [String: [MKOverlay]]()
    
    var mapView: MKMapView!
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.systemBackground
        
        mapView = MKMapView(frame: .zero)
        
        self.view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsBuildings = false
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        mapView.delegate = self
        
        let dataDirectory = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Data")
        let geoJSONDecoder = GeoJSONDecoder()
        venue = geoJSONDecoder.decode(dataDirectory)
        
        if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
            mapView.setVisibleMapRect(venueOverlay.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
            
            for building in venue.buildings {
                print("Rendering \(building.identifier)")
                if let roof = building.levels.last {
                    showFeaturesForLevel(building, roof)
                }
            }
        }
        
        self.navigationItem.title = venue?.properties?.name ?? "Unknown"
    }
    
    func showFeaturesForLevel(_ building: Building, _ level: Level) {
        guard venue != nil else {
            return
        }
        
        if var features = currentLevelFeatures[building.identifier] {
            features.removeAll()
        } else {
            currentLevelFeatures[building.identifier] = [FeatureStyle]()
        }
        
        if var overlays = currentLevelOverlays[building.identifier] {
            mapView.removeOverlays(overlays)
            overlays.removeAll()
        }

        currentLevelFeatures[building.identifier]?.append(level)
        currentLevelFeatures[building.identifier]? += level.units
        
        if let currentLevelGeometry = currentLevelFeatures[building.identifier]?.flatMap({ $0.geometry }) {
            currentLevelOverlays[building.identifier] = currentLevelGeometry.compactMap({ $0 as? MKOverlay })
            mapView.addOverlays(currentLevelOverlays[building.identifier]!)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let shape = overlay as? (MKShape & MKGeoJSONObject),
              let feature = currentLevelFeatures.values.flatMap( {$0} ).first(where: { $0.geometry.contains(where: {$0 == shape}) }) else {
            return MKOverlayRenderer(overlay: overlay)
        }
        
        let renderer: MKOverlayPathRenderer
        switch overlay {
            case is MKMultiPolygon:
                renderer = MKMultiPolygonRenderer(overlay: overlay)
            case is MKPolygon:
                renderer = MKPolygonRenderer(overlay: overlay)
            case is MKMultiPolyline:
                renderer = MKMultiPolylineRenderer(overlay: overlay)
            case is MKPolyline:
                renderer = MKPolylineRenderer(overlay: overlay)
            default:
                return MKOverlayRenderer(overlay: overlay)
        }
        
        feature.configure(overlayRenderer: renderer)

        return renderer
    }
}
