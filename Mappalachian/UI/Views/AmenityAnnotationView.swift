//
//  AmenityAnnotationView.swift
//  Mappalachian
//
//  Created by Wilson Styres on 3/21/21.
//

import UIKit
import MapKit

class AmenityAnnotationView: MKAnnotationView {
    private let annotationFrame = CGRect(x: 0, y: 0, width: 12, height: 12)
    private let imageView: UIImageView
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: annotationFrame.width * 0.7, height: annotationFrame.height * 0.7))
        imageView.tintColor = .white
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = annotationFrame
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
        
        imageView.center = self.center
        self.addSubview(imageView)
    }
    
    var annotationImage: UIImage? {
        didSet {
            imageView.image = annotationImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
}
