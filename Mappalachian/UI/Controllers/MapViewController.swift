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

class MapViewController: UIViewController {

    @IBOutlet var cameraButtonContainer: UIView!
    @IBOutlet var cameraButton: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var buildingLabel: UILabel!
    @IBOutlet var buildingLabelContainer: UIView!
    
    let moc = AppDelegate.delegate().persistentContainer.viewContext
    var polyMap: [MKPolygon: Building] = [MKPolygon: Building]()
    var locationManager: CLLocationManager?
    
    let booneRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.214121, longitude: -81.679117), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.008))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildingLabelContainer.layer.cornerRadius = buildingLabelContainer.frame.height / 4
        
        cameraButtonContainer.layer.cornerRadius = 60 / 2
        cameraButton.image = UIImage(systemName: "camera.fill")
        cameraButton.tintColor = .systemYellow
        
        // Configure mapView to zoom into ASU (at about 36.214121,-81.679117)
        mapView.region = booneRegion
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.tintColor = UIColor(dynamicProvider: { (traits) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return UIColor.systemYellow
            } else {
                return UIColor.black
            }
        })
//        mapView.userTrackingMode = .followWithHeading
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        addPolygons()
    }
    
    func addPolygons() {
        do {
            let buildings = try moc.fetch(NSFetchRequest(entityName: "Building")) as [Building]
            for building in buildings {
                var locationCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
                building.coordinates?.enumerateObjects({ (elem, idx, stop) in
                    let coord = elem as! Coordinate
                    locationCoords.append(CLLocationCoordinate2DMake(coord.lat, coord.long))
                })
                
                let polygon = MKPolygon(coordinates: &locationCoords, count: locationCoords.count)
                polyMap[polygon] = building
                mapView.addOverlay(polygon)
            }
        } catch {
            print("err")
        }
    }
    
    func buildingForUserLocation(_ location: CLLocationCoordinate2D) -> Building? {
        for polygon in polyMap.keys {
            let polygonRenderer = MKPolygonRenderer(polygon: polygon)
            let mapPoint = MKMapPoint(location)
            let polygonPoint = polygonRenderer.point(for: mapPoint)

            if polygonRenderer.path.contains(polygonPoint) {
                return polyMap[polygon]!
            }
        }
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: mapView)
            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            print ("[\(location.latitude), \(location.longitude)],")
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return;
        }
        
        if let building = buildingForUserLocation(mostRecentLocation.coordinate) {
            if buildingLabelContainer.isHidden {
                buildingLabelContainer.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.buildingLabelContainer.alpha = 1.0
                }
            }
            UIView.transition(with: buildingLabel, duration: 0.5, options: .transitionCrossDissolve) {
                self.buildingLabel.text = "\(building.name!)"
            } completion: { (complete) in
                
            }

        } else {
            UIView.animate(withDuration: 0.5) {
                self.buildingLabelContainer.alpha = 0.0
            } completion: { (complete) in
                self.buildingLabelContainer.isHidden = true
            }

        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor(dynamicProvider: { (traits) -> UIColor in
                if traits.userInterfaceStyle == .dark {
                    return UIColor.systemYellow
                } else {
                    return UIColor.black
                }
            }).withAlphaComponent(0.5)
            renderer.strokeColor = UIColor(dynamicProvider: { (traits) -> UIColor in
                if traits.userInterfaceStyle == .dark {
                    return UIColor.systemYellow
                } else {
                    return UIColor.black
                }
            })
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}
