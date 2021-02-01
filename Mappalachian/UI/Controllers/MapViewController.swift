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

class MapViewController: UIViewController, MKMapViewDelegate {
    var locationManager = CLLocationManager()
    
    var venue: Venue?
    var currentLevelOrdinal: Int?
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
        
        currentLevelOrdinal = Int(level.properties?.ordinal ?? 0)
        
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // At a distance of 450, show the units in the levels
        if mapView.camera.centerCoordinateDistance <= 450 {
            let centerPoint = MKMapPoint(mapView.centerCoordinate)
            for overlay in mapView.overlays {
                if let polygon = overlay as? MKPolygon {
                    guard let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer else { continue }
                    let point = renderer.point(for: centerPoint)
                    if renderer.path.contains(point) {
                        let feature = currentLevelFeatures.values.flatMap( {$0} ).first(where: { $0.geometry.contains(where: {$0 == polygon}) })
                        print("\(feature)")
                        break
                    }
                    continue
                }
            }
        }
    }
}
