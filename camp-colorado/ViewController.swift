//
//  ViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/9/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import MapKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var accountBtn: UIButton!
    
    let locationManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 39.189818, longitude: -105.572249)
    
    var campsites = [Campsite]()
    var filteredCampsites = [Campsite]()
    var selectedAnnotation: CampsiteAnnotation!
    var distanceFromUser: CLLocationDistance = 0.0
    var userCurrentLocation: CLLocation?
    var user: User?
    var inSearchMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.layer.cornerRadius = 5.0
        searchBar.clipsToBounds = true
        
        centerMapOnLocation(initialLocation, degrees: 500.0)
        parseCampsitesCSV()
        createAnnotations()
        getUserObject()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
        addUserDistances()
        self.tableView.reloadData()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            map.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            userCurrentLocation = loc
            print(loc)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("span: \(map.region.span)")
        print("center: \(map.region.center)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            view?.annotation = annotation
        }
        
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = createLocationFromCoordinates(view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        if map.region.span.latitudeDelta > 0.7 {
            centerMapOnLocation(location, degrees: 50.0)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? CampsiteAnnotation
            if userCurrentLocation != nil {
                let userLocation = createLocationFromCoordinates(userCurrentLocation!.coordinate.latitude, longitude: userCurrentLocation!.coordinate.longitude)
                let campsiteLocation = createLocationFromCoordinates(selectedAnnotation.latitude, longitude: selectedAnnotation.longitude)
                let distance = getDistanceFromUser(userLocation, locationB: campsiteLocation)
                selectedAnnotation.distanceFromUser = distance
            }
            performSegue(withIdentifier: SEGUE_CAMPSITE_DETAIL, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CampsiteDetailViewController {
            destination.annotation = selectedAnnotation
            destination.user = user
        }
        
        if let destination = segue.destination as? AccountViewController {
            destination.user = user
        }
    }

    func centerMapOnLocation(_ location: CLLocation, degrees: CLLocationDegrees) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * degrees, regionRadius * degrees)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func parseCampsitesCSV() {
        let path = Bundle.main.path(forResource: "campsites-colorado", ofType: "csv")!
        
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
        campsites.sort(by: { $0.distanceFromUser < $1.distanceFromUser })
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
    
    func createLocationFromCoordinates(_ latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDistanceFromUser(_ locationA: CLLocation, locationB: CLLocation) -> Int {
        let distanceInMeters = locationA.distance(from: locationB)
        let distanceInMiles = distanceInMeters * 0.000621371
        return Int(round(distanceInMiles))
    }
    
    func getUserObject() {
        DataService.ds.ref_current_user.observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? Dictionary<String, AnyObject> {
                self.user = User(username: "\(user["username"]!)", userCreatedAt: "\(user["userCreatedAt"]!)", reviewsCount: 0)
                if let reviewsCount = user["reviews"] {
                    self.user!.reviewsCount = reviewsCount.count
                }
                self.accountBtn.isHidden = false
                print(user["username"])
            } else {
                print("no user")
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredCampsites.count
        } else {
            return campsites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var campsite: Campsite
        
        if inSearchMode {
            campsite = filteredCampsites[(indexPath as NSIndexPath).row]
        } else {
            campsite = campsites[(indexPath as NSIndexPath).row]
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CampsiteCell") as? CampsiteCell {
            cell.configureCell(campsite)
            return cell
        } else {
            return CampsiteCell()
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var campsite: Campsite
        
        if inSearchMode {
            campsite = filteredCampsites[(indexPath as NSIndexPath).row]
        } else {
            campsite = campsites[(indexPath as NSIndexPath).row]
        }
        let anno = map.annotations.filter({$0.title! == campsite.sitename})[0]
        let location = createLocationFromCoordinates(campsite.latitude, longitude: campsite.longitude)
        map.selectAnnotation(anno, animated: true)
        centerMapOnLocation(location, degrees: 50.0)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func hideKeyboardWithSearchBar(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
            perform(#selector(ViewController.hideKeyboardWithSearchBar(_:)), with: searchBar, afterDelay: 0)
            tableView.reloadData()
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            filteredCampsites = campsites.filter({$0.sitename.lowercased().range(of: lower) != nil})
            tableView.reloadData()
        }
    }
    
    @IBAction func userLocationPressed(_ sender: AnyObject) {
        centerMapOnLocation(userCurrentLocation!, degrees: 50.0)
    }
    
    @IBAction func accountPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: SEGUE_SHOW_ACCOUNT, sender: self)
    }

}

