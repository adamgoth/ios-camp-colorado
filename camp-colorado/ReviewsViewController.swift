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
    
    @IBOutlet weak var sitenameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var annotation: CampsiteAnnotation!
    var user: User!
    var reviews: [Review] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 270
        
        sitenameLbl.text = annotation.sitename
        
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
            }
            
            self.reviews.sort(by: { $0.reviewDatetime > $1.reviewDatetime })
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = reviews[(indexPath as NSIndexPath).row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as? ReviewCell {
            cell.configureCell(review, img: nil)
            return cell
        } else {
            return ReviewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let review = reviews[(indexPath as NSIndexPath).row]
        
        if review.imageUrl == nil {
            return 170
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AccountViewController {
            destination.user = user
        }
    }
    
    @IBAction func showAccountPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "showAccount", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
