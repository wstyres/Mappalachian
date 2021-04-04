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

class MapViewController: UIViewController, MKMapViewDelegate, LevelPickerDelegate {
    var locationManager = CLLocationManager()
    
    var venue: Venue?
    var currentLevelOrdinal: Int?
    var currentlyRenderedBuilding: Building?
    var currentlyRenderedLevel: Level?
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
        levelPicker.delegate = self

        mapView.addSubview(levelPicker)
        NSLayoutConstraint.activate([
            levelPicker.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8),
            levelPicker.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -8),
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
        
        #if targetEnvironment(macCatalyst)
        let dataDirectory = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Contents/Resources/Data")
        #else
        let dataDirectory = URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("Data")
        #endif
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
        
        if let name = venue?.properties?.name {
            self.title = name
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"), style: .plain, target: self, action: #selector(showInfo))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.tertiaryLabel
        }
    }
    
    private var _title: String?
    override var title: String? {
        set {
            _title = newValue!
            
            if let titleLabel = navigationItem.leftBarButtonItem?.customView as? UILabel {
                let animation = CATransition()
                animation.duration = 0.25
                animation.type = .fade
                
                titleLabel.layer.add(animation, forKey: "fadeText")
                titleLabel.text = _title
            } else {
                let titleLabel = UILabel()
                titleLabel.textColor = .label
                titleLabel.text = _title
                
                let titleFont = UIFont.preferredFont(forTextStyle: .title2)
                let largeTitleFont = UIFont(descriptor: titleFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: titleFont.pointSize)
                titleLabel.font = largeTitleFont
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
            }
        }
        get {
            return _title
        }
    }
    
    func showFeaturesForLevel(_ building: Building, _ level: Level) {
        guard venue != nil else {
            return
        }
        
        currentLevelOrdinal = Int(level.properties?.ordinal ?? 0)
        currentlyRenderedLevel = level
        
        if var overlays = building.renderedOverlays {
            mapView.removeOverlays(overlays)
            overlays.removeAll()
        }
        
        if var annotations = building.renderedAnnotations {
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        var features = [FeatureStyle]()
        if currentLevelOrdinal != building.levels.count - 1 && currentLevelOrdinal! > 0 { // If the level is not the roof
            let lesserLevels = building.levels[0...currentLevelOrdinal! - 1]
            for lesserLevel in lesserLevels {
                features.append(lesserLevel) // Render levels below the current one
            }
        }
        
        features.append(level)
        features += level.units
        features += level.openings
        
        let overlays = features.flatMap({ $0.geometry }).compactMap({ $0 as? MKOverlay })
        building.renderedOverlays = overlays
        mapView.addOverlays(overlays)
        
        let annotations = level.amenities
        building.renderedAnnotations = annotations
        mapView.addAnnotations(annotations)
        
        if currentlyRenderedBuilding != nil && level != building.levels.last {
            var levelNames = building.levels.compactMap({ $0.properties?.shortName })
            levelNames.removeLast()
            levelPicker.levelNames = levelNames
            levelPicker.selectedLevel = level.properties?.ordinal
            
            levelPickerHeightConstraint.constant = CGFloat(levelPicker.levelNames.count * 50)
        } else {
            levelPicker.levelNames = []
            levelPickerHeightConstraint.constant = 0.0
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let feature = annotation as? FeatureStyle {
            let annotationView = AmenityAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
            feature.configure(annotationView: annotationView)
            return annotationView
        }

        return nil
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
        if let level = feature as? Level {
            if level.properties?.ordinal != currentLevelOrdinal {
                renderer.fillColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0) // Renders levels visible below the current level as "closed", similar to the roof.
            }
        }
        
        return renderer
    }
    
    func selectLevel(ordinal: Int) {
        if ordinal == currentLevelOrdinal {
            return
        }
        
        showFeaturesForLevel(currentlyRenderedBuilding!, (currentlyRenderedBuilding?.levels[ordinal])!)
    }
    
    @objc func showInfo() {
        
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
                    self.title = foundBuilding?.properties?.name
                }
                return
            }
        }
        
        if currentlyRenderedBuilding != nil {
            showFeaturesForLevel(currentlyRenderedBuilding!, currentlyRenderedBuilding!.levels.last!)
            currentlyRenderedBuilding = nil
            self.title = venue?.properties?.name
        }
    }
}
