//
//  CampsiteDetailViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/15/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import MapKit

class CampsiteDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sitenameLbl: UILabel!
    @IBOutlet weak var distanceToTownLbl: UILabel!
    @IBOutlet weak var nearestTownLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var numberOfSitesLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    
    var annotation: CampsiteAnnotation!
    var reviews: [Review] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        sitenameLbl.text = annotation.sitename
        distanceToTownLbl.text = annotation.distanceToNearestTown
        nearestTownLbl.text = annotation.nearestTown
        stateLbl.text = annotation.state
        countryLbl.text = annotation.country
        numberOfSitesLbl.text = annotation.numberOfSites
        phoneLbl.text = annotation.phone
        websiteLbl.text = annotation.website
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 270
        
        let review1 = Review(username: "apg", rating: 3, reviewText: "Cool place. Yadda yadda yadda yadda yadda yadda yadda.")
        let review2 = Review(username: "apg", rating: 3, reviewText: "Cool place. Yadda yadda yadda yadda yadda.")
        reviews.append(review1)
        reviews.append(review2)
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
    

    @IBAction func backButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
