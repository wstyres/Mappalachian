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
    var currentlyRenderedBuilding: Building?
    var mapView: MKMapView!
    var levelPicker: LevelPickerView!
    var levelPickerHeightConstraint: NSLayoutConstraint!
    
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
        
        levelPicker = LevelPickerView()

        mapView.addSubview(levelPicker)
        NSLayoutConstraint.activate([
            levelPicker.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8),
            levelPicker.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 8),
            levelPicker.widthAnchor.constraint(equalToConstant: 50),
        ])
        levelPickerHeightConstraint = levelPicker.heightAnchor.constraint(equalToConstant: CGFloat(50 * levelPicker.levelNames.count))
        levelPickerHeightConstraint.isActive = true
        levelPicker.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.showsBuildings = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.delegate = self
        mapView.showsCompass = false
        
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
        
        if var overlays = building.renderedOverlays {
            mapView.removeOverlays(overlays)
            overlays.removeAll()
        }
        
        var features = [FeatureStyle]()
        features.append(level)
        features += level.units
        
        let overlays = features.flatMap({ $0.geometry }).compactMap({ $0 as? MKOverlay })
        building.renderedOverlays = overlays
        mapView.addOverlays(overlays)
        
        
        if currentlyRenderedBuilding != nil && level != building.levels.last {
            var levelNames = building.levels.compactMap({ $0.properties?.shortName })
            levelNames.removeLast()
            levelPicker.levelNames = levelNames
            levelPicker.selectedLevel = level.properties?.ordinal
            
            levelPickerHeightConstraint.constant = CGFloat(levelPicker.levelNames.count * 50)
            levelPicker.isHidden = false
        } else {
            levelPicker.isHidden = true
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let feature = venue?.featureForShape(overlay, on: currentLevelOrdinal!) else {
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
            var foundBuilding: Building? = nil
            for overlay in mapView.overlays {
                if let polygon = overlay as? MKPolygon {
                    guard let renderer = mapView.renderer(for: polygon) as? MKPolygonRenderer else { continue }
                    let point = renderer.point(for: centerPoint)
                    if renderer.path.contains(point) {
                        if let building = venue?.buildings.first(where: { $0.renderedOverlays?.contains(where: { $0.isEqual(overlay) }) as! Bool }) {
                            foundBuilding = building
                            break
                        }
                    }
                }
            }
            
            if foundBuilding != nil {
                if currentlyRenderedBuilding != foundBuilding {
                    if currentlyRenderedBuilding != nil {
                        showFeaturesForLevel(currentlyRenderedBuilding!, currentlyRenderedBuilding!.levels.last!)
                    }
                    currentlyRenderedBuilding = foundBuilding
                    showFeaturesForLevel(foundBuilding!, foundBuilding!.levels[foundBuilding!.levels.count - 2])
                    self.navigationItem.title = foundBuilding?.properties?.name
                }
            } else if currentlyRenderedBuilding != nil {
                showFeaturesForLevel(currentlyRenderedBuilding!, currentlyRenderedBuilding!.levels.last!)
                currentlyRenderedBuilding = nil
                
                self.navigationItem.title = venue?.properties?.name
            }
        } else if currentlyRenderedBuilding != nil {
            showFeaturesForLevel(currentlyRenderedBuilding!, currentlyRenderedBuilding!.levels.last!)
            currentlyRenderedBuilding = nil
            self.navigationItem.title = venue?.properties?.name
        }
    }
}
