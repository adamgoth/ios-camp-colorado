//
//  CampsiteDetailViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/15/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CampsiteDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sitenameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var coordinatesLbl: UILabel!
    @IBOutlet weak var numberOfSitesLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var reviewStar1: UIButton!
    @IBOutlet weak var reviewStar2: UIButton!
    @IBOutlet weak var reviewStar3: UIButton!
    @IBOutlet weak var reviewStar4: UIButton!
    @IBOutlet weak var reviewStar5: UIButton!
    @IBOutlet weak var reviewTextField: UITextField!
    
    let regionRadius: CLLocationDistance = 1000
    var annotation: CampsiteAnnotation!
    var user: User!
    var reviews: [Review] = []
    var starsSelected: Bool = false
    var starRating: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        let location = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
        annotation.coordinate = location.coordinate
        map.addAnnotation(annotation)
        centerMapOnLocation(location)

        sitenameLbl.text = annotation.sitename
        coordinatesLbl.text = "Latitude: \(annotation.latitude)   Longitude: \(annotation.longitude)"
        
        if annotation.numberOfSites != "" {
            numberOfSitesLbl.text = "Number of campsites: \(annotation.numberOfSites)"
        } else {
            numberOfSitesLbl.hidden = true
        }
        
        if annotation.phone != "" {
            phoneLbl.text = annotation.phone
        } else {
            phoneLbl.hidden = true
        }
        
        if annotation.website != "" {
            websiteLbl.text = annotation.website
        } else {
            websiteLbl.hidden = true
        }
        
        if annotation.distanceToNearestTown != "" && annotation.nearestTown != "" {
            locationLbl.text = "Located \(annotation.distanceToNearestTown) miles from \(annotation.nearestTown), \(annotation.state), \(annotation.country)"
        } else {
            "\(annotation.state), \(annotation.country)"
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 270
        
        DataService.ds.ref_reviews.child("\(annotation.campsiteId)").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            self.reviews = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let reviewDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let review = Review(reviewKey: key, dictionary: reviewDict)
                        self.reviews.append(review)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 0.5, regionRadius * 0.5)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let review = reviews[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell") as? ReviewCell {
            cell.configureCell(review, img: nil)
            return cell
        } else {
            return ReviewCell()
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let review = reviews[indexPath.row]
        
        if review.imageUrl == nil {
            return 180
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? AccountViewController {
            destination.user = user
        }
    }
    
    func postToFirebase() {
        var review: Dictionary<String, AnyObject> = [
            "username": user.username,
            "reviewText": reviewTextField.text!,
            "helpful": 0,
            "rating": starRating,
            "reviewDatetime": NSDate().timeIntervalSince1970
        ]

        
        let firebasePost = DataService.ds.ref_reviews.child("\(annotation.campsiteId)").childByAutoId()
        firebasePost.setValue(review)
        
        reviewTextField.text = ""
        starRating = 0
        starsSelected = false
    }
    
    func showErrorAlert(alert: String, message: String) {
        let alert = UIAlertController(title: alert, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func makeReview(sender: AnyObject) {
        if starsSelected {
            if let text = reviewTextField.text where text != "" {
                self.postToFirebase()
            } else {
                showErrorAlert("No Review Text", message: "Use must leave text in your review")
            }
        } else {
            showErrorAlert("No Rating Selected", message: "Use the stars to add a rating to your review")
        }
    }
    
    @IBAction func reviewStar1Pressed(sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar2.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        reviewStar3.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        reviewStar4.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        reviewStar5.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        starsSelected = true
        starRating = 1
    }
    
    @IBAction func reviewStar2Pressed(sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar2.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar3.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        reviewStar4.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        reviewStar5.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        starsSelected = true
        starRating = 2
    }
    
    @IBAction func reviewStar3Pressed(sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar2.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar3.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar4.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        reviewStar5.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        starsSelected = true
        starRating = 3
    }
    
    @IBAction func reviewStar4Pressed(sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar2.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar3.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar4.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar5.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
        starsSelected = true
        starRating = 4
    }
    
    @IBAction func reviewStar5Pressed(sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar2.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar3.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar4.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        reviewStar5.setImage(UIImage(named: "full-star"), forState: UIControlState.Normal)
        starsSelected = true
        starRating = 5
    }
    
    @IBAction func accountPressed(sender: AnyObject) {
        performSegueWithIdentifier("showAccount", sender: self)
    }
    

    @IBAction func backButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
