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
    @IBOutlet weak var reviewCell: ReviewCell!
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
            numberOfSitesLbl.isHidden = true
        }
        
        if annotation.phone != "" {
            phoneLbl.text = annotation.phone
        } else {
            phoneLbl.isHidden = true
        }
        
        if annotation.website != "" {
            websiteLbl.text = annotation.website
        } else {
            websiteLbl.isHidden = true
        }
        
        if annotation.distanceToNearestTown != "" && annotation.nearestTown != "" {
            locationLbl.text = "Located \(annotation.distanceToNearestTown) miles from \(annotation.nearestTown), \(annotation.state), \(annotation.country)"
        } else {
            locationLbl.text = "\(annotation.state), \(annotation.country)"
        }
        
        if annotation.distanceFromUser != nil {
            distanceFromUserLbl.text = "\(annotation.distanceFromUser!) miles away"
        } else {
            distanceFromUserLbl.isHidden = true
        }
        
        fetchReviews()
        
    }
        
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 0.5, regionRadius * 0.5)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func showErrorAlert(_ alert: String, message: String) {
        let alert = UIAlertController(title: alert, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //get reviews
    func fetchReviews() {
        DataService.ds.ref_reviews.child("\(annotation.campsiteId)").observe(FIRDataEventType.value, with: { (snapshot) in
            
            self.reviews = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let reviewDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let review = Review(reviewKey: key, dictionary: reviewDict)
                        self.reviews.append(review)
                    }
                }
                
                if self.reviews.count > 0 {
                    self.calculateAverageRating()
                    self.reviewDisplayView.isHidden = false
                    self.seeAllReviewsBtn.isHidden = false
                    self.beTheFirstView.isHidden = true
                    self.ratingAndNumberView.isHidden = false
                    self.numberOfReviewsLbl.text = "\(self.reviews.count) reviews, \(self.averageRating) average rating"
                    self.getLatestReview()
                } else {
                    self.reviewDisplayView.isHidden = true
                    self.seeAllReviewsBtn.isHidden = true
                    self.beTheFirstView.isHidden = false
                }
            }
        })
    }
    
    func getLatestReview() {
        self.reviews.sort(by: { $0.reviewDatetime > $1.reviewDatetime })
        let displayReview = reviews[0]
        reviewCell.configureCell(displayReview, img: nil)
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
    
    //post review
    func postToFirebase() {
        let review: Dictionary<String, AnyObject> = [
            "campsiteId": annotation.campsiteId as AnyObject,
            "username": user.username as AnyObject,
            "reviewText": reviewTextField.text! as AnyObject,
            "helpful": 0 as AnyObject,
            "rating": starRating as AnyObject,
            "reviewDatetime": Date().timeIntervalSince1970 as AnyObject
        ]
        
        
        let firebasePost = DataService.ds.ref_reviews.child("\(annotation.campsiteId)").childByAutoId()
        firebasePost.setValue(review)
        
        reviewTextField.text = ""
        starRating = 0
        starsSelected = false
    }
    
    @IBAction func makeReview(_ sender: AnyObject) {
        if starsSelected {
            if let text = reviewTextField.text , text != "" {
                self.postToFirebase()
                reviewTextField.text = ""
                reviewTextField.endEditing(true)
                reviewStar1.setImage(UIImage(named: "empty-star"), for: UIControlState())
                reviewStar2.setImage(UIImage(named: "empty-star"), for: UIControlState())
                reviewStar3.setImage(UIImage(named: "empty-star"), for: UIControlState())
                reviewStar4.setImage(UIImage(named: "empty-star"), for: UIControlState())
                reviewStar5.setImage(UIImage(named: "empty-star"), for: UIControlState())
                performSegue(withIdentifier: "showAllReviews", sender: self)
                
            } else {
                showErrorAlert("Nothing to say?", message: "Tell us about your visit")
            }
        } else {
            showErrorAlert("Did you enjoy this campsite?", message: "Use the stars to add a rating to your review")
        }
    }
    
    @IBAction func reviewStar1Pressed(_ sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar2.setImage(UIImage(named: "empty-star"), for: UIControlState())
        reviewStar3.setImage(UIImage(named: "empty-star"), for: UIControlState())
        reviewStar4.setImage(UIImage(named: "empty-star"), for: UIControlState())
        reviewStar5.setImage(UIImage(named: "empty-star"), for: UIControlState())
        starsSelected = true
        starRating = 1
    }
    
    @IBAction func reviewStar2Pressed(_ sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar2.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar3.setImage(UIImage(named: "empty-star"), for: UIControlState())
        reviewStar4.setImage(UIImage(named: "empty-star"), for: UIControlState())
        reviewStar5.setImage(UIImage(named: "empty-star"), for: UIControlState())
        starsSelected = true
        starRating = 2
    }
    
    @IBAction func reviewStar3Pressed(_ sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar2.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar3.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar4.setImage(UIImage(named: "empty-star"), for: UIControlState())
        reviewStar5.setImage(UIImage(named: "empty-star"), for: UIControlState())
        starsSelected = true
        starRating = 3
    }
    
    @IBAction func reviewStar4Pressed(_ sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar2.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar3.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar4.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar5.setImage(UIImage(named: "empty-star"), for: UIControlState())
        starsSelected = true
        starRating = 4
    }
    
    @IBAction func reviewStar5Pressed(_ sender: AnyObject) {
        reviewStar1.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar2.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar3.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar4.setImage(UIImage(named: "full-star"), for: UIControlState())
        reviewStar5.setImage(UIImage(named: "full-star"), for: UIControlState())
        starsSelected = true
        starRating = 5
    }
    
    @IBAction func allReviewsPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: SEGUE_SHOW_ALL_REVIEWS, sender: self)
    }
    
    @IBAction func accountPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: SEGUE_SHOW_ACCOUNT, sender: self)
    }
    
    @IBAction func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ReviewsViewController {
            destination.annotation = annotation
            destination.user = user
        }
        
        if let destination = segue.destination as? AccountViewController {
            destination.user = user
        }
    }

}
