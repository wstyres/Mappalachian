//
//  MapViewController.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/20/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet var cameraButtonContainer: UIView!
    @IBOutlet var cameraButton: UIImageView!
    @IBOutlet var mapView: MKMapView!
    
    let booneRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 36.214121, longitude: -81.679117), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.008))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButtonContainer.layer.cornerRadius = 60 / 2
        cameraButton.image = UIImage(systemName: "camera.fill")
        cameraButton.tintColor = .systemGroupedBackground
        
        // Configure mapView to zoom into ASU (at about 36.214121,-81.679117)
        mapView.region = booneRegion
    }
    
    

}
