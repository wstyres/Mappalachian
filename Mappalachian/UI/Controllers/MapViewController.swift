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
        overlayRenderer.strokeColor = UIColor.blue
        overlayRenderer.lineWidth = 2.0
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    var locationManager = CLLocationManager()
    
    var venue: Venue?
    var levels: [Level] = []
    var currentLevelFeatures = [FeatureStyle]()
    var currentLevelOverlays = [MKOverlay]()
    var currentLevelAnnotations = [MKAnnotation]()
    
    @IBOutlet var cameraButtonContainer: UIView!
    @IBOutlet var cameraButton: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var buildingLabel: UILabel!
    @IBOutlet var buildingLabelContainer: UIView!
    
//    let booneRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.214121, longitude: -81.679117), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.008))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        let dataDirectory = URL(fileURLWithPath: Bundle.main.bundlePath)
        let geoJSONDecoder = GeoJSONDecoder()
        venue = geoJSONDecoder.decode(dataDirectory)
        
        if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
            mapView.setVisibleMapRect(venueOverlay.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        }
        
        showFeaturesForFloor(1)
    }
    
    func showFeaturesForFloor(_ floor: Int) {
        guard venue != nil else {
            return
        }

        // Clear out the previously-displayed level's geometry
        currentLevelFeatures.removeAll()
        mapView.removeOverlays(self.currentLevelOverlays)
        mapView.removeAnnotations(self.currentLevelAnnotations)
        currentLevelAnnotations.removeAll()
        currentLevelOverlays.removeAll()

        // Display the level's footprint, unit footprints, opening geometry, and occupant annotations
        if let levels = self.venue?.levelsByOrdinal[floor] {
            for level in levels {
                self.currentLevelFeatures.append(level)
            }
        }
        
        let currentLevelGeometry = self.currentLevelFeatures.flatMap({ $0.geometry })
        currentLevelOverlays = currentLevelGeometry.compactMap({ $0 as? MKOverlay })

//        mapView.addOverlays(currentLevelOverlays, level: MKOverlayLevel(rawValue: 1))
        mapView.addOverlays(currentLevelOverlays)
        mapView.addAnnotations(currentLevelAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let shape = overlay as? (MKShape & MKGeoJSONObject),
            let feature = currentLevelFeatures.first( where: { $0.geometry.contains( where: { $0 == shape }) }) else {
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

        // Configure the overlay renderer's display properties in feature-specific ways.
        feature.configure(overlayRenderer: renderer)

        return renderer
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let touchPoint = touch.location(in: mapView)
//            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//            print ("[\(location.latitude), \(location.longitude)],")
//        }
//    }
    
    @IBAction func selectOne(_ sender: Any) {
        showFeaturesForFloor(1)
    }
    
    @IBAction func selectTwo(_ sender: Any) {
        showFeaturesForFloor(0)
    }
}
