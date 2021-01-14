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
        overlayRenderer.fillColor = UIColor.white
        overlayRenderer.lineWidth = 2.0
    }
}

extension Unit: FeatureStyle {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if self.properties?.category == "office" {
            overlayRenderer.fillColor = UIColor(red: 0.83, green: 0.98, blue: 0.84, alpha: 1.00)
        } else if self.properties?.category == "elevator" {
            overlayRenderer.fillColor = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        } else if self.properties?.category == "storage" {
            overlayRenderer.fillColor = UIColor(red: 0.96, green: 0.84, blue: 0.73, alpha: 1.00)
        } else if self.properties?.category == "conferenceroom" {
            overlayRenderer.fillColor = UIColor(red: 0.65, green: 0.85, blue: 0.97, alpha: 1.00)
        } else if self.properties?.category == "privatelounge" {
            overlayRenderer.fillColor = UIColor(red: 0.96, green: 0.90, blue: 0.39, alpha: 1.00)
        } else if self.properties?.category == "mailroom" {
            overlayRenderer.fillColor = UIColor(red: 1.00, green: 0.68, blue: 0.41, alpha: 1.00)
        } else if self.properties?.category == "serverroom" {
            overlayRenderer.fillColor = UIColor(red: 0.93, green: 0.82, blue: 0.88, alpha: 1.00)
        } else if self.properties?.category == "laboratory" {
            overlayRenderer.fillColor = UIColor(red: 0.76, green: 1.00, blue: 0.95, alpha: 1.00)
        } else {
            overlayRenderer.fillColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        }
        overlayRenderer.strokeColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 190/255)
        overlayRenderer.lineWidth = 1.3
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
        
        mapView.showsBuildings = false
        mapView.delegate = self
        
        let dataDirectory = URL(fileURLWithPath: Bundle.main.bundlePath)
        let geoJSONDecoder = GeoJSONDecoder()
        venue = geoJSONDecoder.decode(dataDirectory)
        
        if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
            mapView.setVisibleMapRect(venueOverlay.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        }
        
        showFeaturesForFloor(2)
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
                self.currentLevelFeatures += level.units
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
    
    @IBAction func selectOne(_ sender: Any) {
        showFeaturesForFloor(1)
    }
    
    @IBAction func selectTwo(_ sender: Any) {
        showFeaturesForFloor(0)
    }
}
