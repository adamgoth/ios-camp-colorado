//
//  ViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/9/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 39.12921, longitude: -105.693681)
    
    var campsites = [Campsite]()
    var selectedAnnotation: CampsiteAnnotation!
    var distanceFromUser: CLLocationDistance = 0.0
    var userCurrentLocation: CLLocation?
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.layer.cornerRadius = 5.0
        searchBar.clipsToBounds = true
        
        centerMapOnLocation(initialLocation, degrees: 500.0)
        parseCampsitesCSV()
        createAnnotations()
        getUserObject()
    }
    
    override func viewDidAppear(animated: Bool) {
        locationAuthStatus()
        addUserDistances()
        self.tableView.reloadData()
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
            userCurrentLocation = loc
            print(loc)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(map.region.span)
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

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let location = createLocationFromCoordinates(view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        if map.region.span.latitudeDelta > 0.7 {
            centerMapOnLocation(location, degrees: 50.0)
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? CampsiteAnnotation
            if userCurrentLocation != nil {
                let userLocation = createLocationFromCoordinates(userCurrentLocation!.coordinate.latitude, longitude: userCurrentLocation!.coordinate.longitude)
                let campsiteLocation = createLocationFromCoordinates(selectedAnnotation.latitude, longitude: selectedAnnotation.longitude)
                let distance = getDistanceFromUser(userLocation, locationB: campsiteLocation)
                selectedAnnotation.distanceFromUser = distance
            }
            performSegueWithIdentifier("showCampsiteDetail", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? CampsiteDetailViewController {
            destination.annotation = selectedAnnotation
            destination.user = user
        }
        
        if let destination = segue.destinationViewController as? AccountViewController {
            destination.user = user
        }
    }

    func centerMapOnLocation(location: CLLocation, degrees: CLLocationDegrees) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * degrees, regionRadius * degrees)
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
                let state = row["state"]!
                let country = row["country"]!
                let nearestTown = row["nearesttown"]!
                let distanceToNearestTown = row["distancefromtown"]!
                let numberOfSites = row["numberofsites"]!
                let phone = row["phone"]!
                let website = row["website"]!
                let campsite = Campsite(campsiteId: campsiteId, sitename: sitename, latitude: latitude, longitude: longitude, state: state, country: country, nearestTown: nearestTown, distanceToNearestTown: distanceToNearestTown, numberOfSites: numberOfSites, phone: phone, website: website)
                
                campsites.append(campsite)
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    func addUserDistances() {
        for campsite in campsites {
            if let userLocation = userCurrentLocation {
                let distance = getDistanceFromUser(userLocation, locationB: CLLocation(latitude: campsite.latitude, longitude: campsite.longitude))
                campsite.distanceFromUser = distance
            }
        }
        campsites.sortInPlace({ $0.distanceFromUser < $1.distanceFromUser })
    }
    
    func createAnnotations() {
        let allAnnotations = self.map.annotations
        map.removeAnnotations(allAnnotations)
        for campsite in campsites {
            let location = createLocationFromCoordinates(campsite.latitude, longitude: campsite.longitude)
            let anno = CampsiteAnnotation(sitename: campsite.sitename, campsiteId: campsite.campsiteId, latitude: campsite.latitude, longitude: campsite.longitude, state: campsite.state, country: campsite.country, nearestTown: campsite.nearestTown, distanceToNearestTown: campsite.distanceToNearestTown, numberOfSites: campsite.numberOfSites, phone: campsite.phone, website: campsite.website, distanceFromUser: campsite.distanceFromUser)
            if let userLocation = userCurrentLocation {
                let distance = getDistanceFromUser(userLocation, locationB: location)
                anno.subtitle = "\(distance) miles away"
            } else if campsite.numberOfSites != "" {
                anno.subtitle = "\(campsite.numberOfSites) campsites"
            } else {
                anno.subtitle = ""
            }
            anno.coordinate = location.coordinate
            anno.title = campsite.sitename
            map.addAnnotation(anno)
        }
    }
    
    func createLocationFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDistanceFromUser(locationA: CLLocation, locationB: CLLocation) -> Int {
        let distanceInMeters = locationA.distanceFromLocation(locationB)
        let distanceInMiles = distanceInMeters * 0.000621371
        return Int(round(distanceInMiles))
    }
    
    func getUserObject() {
        DataService.ds.ref_current_user.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let user = snapshot.value as? Dictionary<String, AnyObject> {
                self.user = User(username: "\(user["username"]!)")
            } else {
                print("no user")
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campsites.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let campsite = campsites[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CampsiteCell") as? CampsiteCell {
            cell.configureCell(campsite)
            return cell
        } else {
            return CampsiteCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let campsite = campsites[indexPath.row]
        let anno = map.annotations.filter({$0.title! == campsite.sitename})[0]
        let location = createLocationFromCoordinates(campsite.latitude, longitude: campsite.longitude)
        map.selectAnnotation(anno, animated: true)
        centerMapOnLocation(location, degrees: 50.0)
    }
    
    @IBAction func userLocationPressed(sender: AnyObject) {
        centerMapOnLocation(userCurrentLocation!, degrees: 50.0)
    }
    
    @IBAction func accountPressed(sender: AnyObject) {
        performSegueWithIdentifier("showAccount", sender: self)
    }

}

