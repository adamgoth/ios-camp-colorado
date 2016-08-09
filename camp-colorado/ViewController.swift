//
//  ViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/9/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        let initialLocation = CLLocation(latitude: 39.12921, longitude: -105.693681)
        centerMapOnLocation(initialLocation)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(map.region.center)
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 600.0, regionRadius * 600.0)
        map.setRegion(coordinateRegion, animated: true)
    }

}

