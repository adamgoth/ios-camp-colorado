//
//  ReviewsViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/30/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var annotation: CampsiteAnnotation!
    var user: User!
    var reviews: [Review] = []

    override func viewDidLoad() {
        super.viewDidLoad()

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

}
