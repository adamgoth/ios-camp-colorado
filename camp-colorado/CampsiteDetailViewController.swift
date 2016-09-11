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

class CampsiteDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    //detail outlets
    @IBOutlet weak var sitenameLbl: UILabel!
    @IBOutlet weak var distanceFromUserLbl: UILabel!
    @IBOutlet weak var ratingAndNumberView: UIStackView!
    @IBOutlet weak var numberOfReviewsLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var coordinatesLbl: UILabel!
    @IBOutlet weak var numberOfSitesLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var averageRatingStar1: UIImageView!
    @IBOutlet weak var averageRatingStar2: UIImageView!
    @IBOutlet weak var averageRatingStar3: UIImageView!
    @IBOutlet weak var averageRatingStar4: UIImageView!
    @IBOutlet weak var averageRatingStar5: UIImageView!
    //new review outlets
    @IBOutlet weak var reviewStar1: UIButton!
    @IBOutlet weak var reviewStar2: UIButton!
    @IBOutlet weak var reviewStar3: UIButton!
    @IBOutlet weak var reviewStar4: UIButton!
    @IBOutlet weak var reviewStar5: UIButton!
    @IBOutlet weak var reviewTextField: UITextField!
    //review display outlets
    @IBOutlet weak var beTheFirstView: UIView!
    @IBOutlet weak var reviewDisplayView: UIView!
    @IBOutlet weak var seeAllReviewsBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var reviewDatetimeLbl: UILabel!
    @IBOutlet weak var helpfulImg: UIImageView!
    @IBOutlet weak var reviewTxt: UITextView!
    @IBOutlet weak var reviewStarDisplay1: UIImageView!
    @IBOutlet weak var reviewStarDisplay2: UIImageView!
    @IBOutlet weak var reviewStarDisplay3: UIImageView!
    @IBOutlet weak var reviewStarDisplay4: UIImageView!
    @IBOutlet weak var reviewStarDisplay5: UIImageView!
    
    let regionRadius: CLLocationDistance = 1000
    var annotation: CampsiteAnnotation!
    var user: User!
    var reviews: [Review] = []
    var starsSelected: Bool = false
    var starRating: Int = 0
    var averageRating: Double = 0.0

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
        
        if annotation.distanceFromUser != nil {
            distanceFromUserLbl.text = "\(annotation.distanceFromUser!) miles away"
        } else {
            distanceFromUserLbl.hidden = true
        }
        
        fetchReviews()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.reviews.count > 0 {
            calculateAverageRating()
            reviewDisplayView.hidden = false
            seeAllReviewsBtn.hidden = false
            beTheFirstView.hidden = true
            ratingAndNumberView.hidden = false
            numberOfReviewsLbl.text = "\(self.reviews.count) reviews, \(averageRating) average rating"
            getLatestReview()
        } else {
            reviewDisplayView.hidden = true
            seeAllReviewsBtn.hidden = true
            beTheFirstView.hidden = false
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 0.5, regionRadius * 0.5)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ReviewsViewController {
            destination.annotation = annotation
            destination.user = user
        }
        
        if let destination = segue.destinationViewController as? AccountViewController {
            destination.user = user
        }
    }
    
    func postToFirebase() {
        let review: Dictionary<String, AnyObject> = [
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
    
    func fetchReviews() {
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
        })
    }
    
    func getLatestReview() {
        self.reviews.sortInPlace({ $0.reviewDatetime > $1.reviewDatetime })
        let displayReview = reviews[0]
        usernameLbl.text = displayReview.username
        reviewDatetimeLbl.text = "\(NSDate(timeIntervalSince1970: displayReview.reviewDatetime).dayMonthTime()!)"
        reviewTxt.text = "\(displayReview.reviewText)"
        
        switch displayReview.rating {
        case 1:
            reviewStarDisplay1.image = UIImage(named: "full-star")
            reviewStarDisplay2.image = UIImage(named: "empty-star")
            reviewStarDisplay3.image = UIImage(named: "empty-star")
            reviewStarDisplay4.image = UIImage(named: "empty-star")
            reviewStarDisplay5.image = UIImage(named: "empty-star")
        case 2:
            reviewStarDisplay1.image = UIImage(named: "full-star")
            reviewStarDisplay2.image = UIImage(named: "full-star")
            reviewStarDisplay3.image = UIImage(named: "empty-star")
            reviewStarDisplay4.image = UIImage(named: "empty-star")
            reviewStarDisplay5.image = UIImage(named: "empty-star")
        case 3:
            reviewStarDisplay1.image = UIImage(named: "full-star")
            reviewStarDisplay2.image = UIImage(named: "full-star")
            reviewStarDisplay3.image = UIImage(named: "full-star")
            reviewStarDisplay4.image = UIImage(named: "empty-star")
            reviewStarDisplay5.image = UIImage(named: "empty-star")
        case 4:
            reviewStarDisplay1.image = UIImage(named: "full-star")
            reviewStarDisplay2.image = UIImage(named: "full-star")
            reviewStarDisplay3.image = UIImage(named: "full-star")
            reviewStarDisplay4.image = UIImage(named: "full-star")
            reviewStarDisplay5.image = UIImage(named: "empty-star")
        case 5:
            reviewStarDisplay1.image = UIImage(named: "full-star")
            reviewStarDisplay2.image = UIImage(named: "full-star")
            reviewStarDisplay3.image = UIImage(named: "full-star")
            reviewStarDisplay4.image = UIImage(named: "full-star")
            reviewStarDisplay5.image = UIImage(named: "full-star")
        default:
            reviewStarDisplay1.image = UIImage(named: "empty-star")
            reviewStarDisplay2.image = UIImage(named: "empty-star")
            reviewStarDisplay3.image = UIImage(named: "empty-star")
            reviewStarDisplay4.image = UIImage(named: "empty-star")
            reviewStarDisplay5.image = UIImage(named: "empty-star")
        }
    }
    
    func calculateAverageRating() {
        let total = self.reviews.reduce(0) { $0 + $1.rating }
        let reviews = self.reviews.count
        let averaged = Double(total)/Double(reviews)
        print(averaged)
        averageRating = averaged
        if averageRating >= 4.5 {
            averageRatingStar1.image = UIImage(named: "full-star")
            averageRatingStar2.image = UIImage(named: "full-star")
            averageRatingStar3.image = UIImage(named: "full-star")
            averageRatingStar4.image = UIImage(named: "full-star")
            averageRatingStar5.image = UIImage(named: "full-star")
        } else if averageRating >= 3.5 {
            averageRatingStar1.image = UIImage(named: "full-star")
            averageRatingStar2.image = UIImage(named: "full-star")
            averageRatingStar3.image = UIImage(named: "full-star")
            averageRatingStar4.image = UIImage(named: "full-star")
        } else if averageRating >= 2.5 {
            averageRatingStar1.image = UIImage(named: "full-star")
            averageRatingStar2.image = UIImage(named: "full-star")
            averageRatingStar3.image = UIImage(named: "full-star")
        } else if averageRating >= 1.5 {
            averageRatingStar1.image = UIImage(named: "full-star")
            averageRatingStar2.image = UIImage(named: "full-star")
        } else if averageRating >= 0.5 {
            averageRatingStar1.image = UIImage(named: "full-star")
        }
    }
    
    @IBAction func makeReview(sender: AnyObject) {
        if starsSelected {
            if let text = reviewTextField.text where text != "" {
                self.postToFirebase()
                reviewTextField.text = ""
                reviewTextField.endEditing(true)
                reviewStar1.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
                reviewStar2.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
                reviewStar3.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
                reviewStar4.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
                reviewStar5.setImage(UIImage(named: "empty-star"), forState: UIControlState.Normal)
                performSegueWithIdentifier("showAllReviews", sender: self)
                
            } else {
                showErrorAlert("Nothing to say?", message: "Tell us about your visit")
            }
        } else {
            showErrorAlert("Did you enjoy this campsite?", message: "Use the stars to add a rating to your review")
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
    
    @IBAction func allReviewsPressed(sender: AnyObject) {
        performSegueWithIdentifier(SEGUE_SHOW_ALL_REVIEWS, sender: self)
    }
    
    @IBAction func accountPressed(sender: AnyObject) {
        performSegueWithIdentifier(SEGUE_SHOW_ACCOUNT, sender: self)
    }
    

    @IBAction func backButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
