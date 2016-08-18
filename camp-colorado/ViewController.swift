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
    
    let locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 39.12921, longitude: -105.693681)
    
    var campsites = [Campsite]()
    var selectedAnnotation: CampsiteAnnotation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        centerMapOnLocation(initialLocation)
        
        parseCampsitesCSV()
        createAnnotations()
    }
    
    override func viewDidAppear(animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            map.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            print(loc)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(map.region.center)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? CampsiteAnnotation
            performSegueWithIdentifier("showCampsiteDetail", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? CampsiteDetailViewController {
            destination.annotation = selectedAnnotation
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 600.0, regionRadius * 600.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func parseCampsitesCSV() {
        let path = NSBundle.mainBundle().pathForResource("campsites-colorado", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let campsiteId = Int(row["id"]!)!
                let sitename = row["sitename"]!
                let latitude = CLLocationDegrees(row["latitude"]!)!
                let longitude = CLLocationDegrees(row["longitude"]!)!
                let campsite = Campsite(campsiteId: campsiteId, sitename: sitename, latitude: latitude, longitude: longitude)
                campsites.append(campsite)
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func createAnnotations() {
        for campsite in campsites {
            let location = createLocationFromCoordinates(campsite.latitude, longitude: campsite.longitude)
            let anno = CampsiteAnnotation(sitename: campsite.sitename, campsiteId: campsite.campsiteId)
            anno.coordinate = location.coordinate
            anno.title = campsite.sitename
            anno.subtitle = "Subtitle"
            map.addAnnotation(anno)
        }
    }
    
    func createLocationFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

}

