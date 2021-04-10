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
    var searchView: UIView!
    var currentlyHighlightedOverlay: MKOverlay?
    
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
        
        searchView = UIView()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        searchView.addSubview(blurView)
        mapView.addSubview(searchView)
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: levelPicker.bottomAnchor, constant: 8),
            searchView.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -8),
            searchView.heightAnchor.constraint(equalToConstant: 50),
            searchView.widthAnchor.constraint(equalToConstant: 50),
            blurView.topAnchor.constraint(equalTo: searchView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: searchView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: searchView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: searchView.trailingAnchor),
        ])
        blurView.translatesAutoresizingMaskIntoConstraints = false
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.layer.cornerRadius = 10
        blurView.layer.masksToBounds = true
        
        searchView.layer.shadowColor = UIColor.black.cgColor
        searchView.layer.shadowOffset = CGSize(width: 0, height: 1)
        searchView.layer.shadowOpacity = 0.4
        searchView.layer.shadowRadius = 3.0
        
        let searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        searchButton.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig), for: .normal)
        searchButton.tintColor = UIColor.label
        searchButton.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
        
        blurView.contentView.addSubview(searchButton)
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
    
    private var _secondaryTitle: String?
    var secondaryTitle: String? {
        set {
            _secondaryTitle = newValue!
            
            if let titleLabel = navigationItem.rightBarButtonItem?.customView as? UILabel {
                let animation = CATransition()
                animation.duration = 0.25
                animation.type = .fade
                
                titleLabel.layer.add(animation, forKey: "fadeText")
                titleLabel.text = _secondaryTitle
            } else {
                let titleLabel = UILabel()
                titleLabel.textColor = .secondaryLabel
                titleLabel.text = _secondaryTitle
                
                let titleFont = UIFont.preferredFont(forTextStyle: .title3)
                let largeTitleFont = UIFont(descriptor: titleFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: titleFont.pointSize)
                titleLabel.font = largeTitleFont
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: titleLabel)
            }
        }
        get {
            return _secondaryTitle
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
            self.secondaryTitle = "Floor \(level.properties!.ordinal + 1)"
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
        if overlay.isEqual(currentlyHighlightedOverlay) {
            renderer.strokeColor = .systemPink
        }
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
    
    @objc func showSearch() {
        let search = SearchViewController(building: currentlyRenderedBuilding!.identifier)
        let nav = UINavigationController(rootViewController: search)
        self.present(nav, animated: true, completion: nil)
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
            self.secondaryTitle = ""
        }
    }
    
    func focusOnRoom(room: String, in building: String) {
        print("Focusing on \(building) \(room)")
        
        let building = venue?.buildings.first(where: { $0.identifier == building} )
        var foundUnit: Unit?
        var foundLevel: Level?
        
        // This is a little strange but doing it any other way would assume too much about the layout of the building
        for level in building!.levels {
            for unit in level.units {
                if unit.identifier == room {
                    foundUnit = unit
                    foundLevel = level
                    break
                }
            }
            if foundUnit != nil && foundLevel != nil {
                break
            }
        }
        
        if foundUnit != nil && foundLevel != nil {
            if let bounds = foundUnit!.geometry[0] as? MKOverlay {
                mapView.setVisibleMapRect(bounds.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if foundLevel?.properties?.ordinal != self.currentLevelOrdinal {
                    self.showFeaturesForLevel(building!, foundLevel!)
                }
            }
        }
    }
    
}
