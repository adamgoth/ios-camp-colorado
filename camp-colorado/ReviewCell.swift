//
//  ReviewCell.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/19/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase

class ReviewCell: UITableViewCell, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var reviewDatetimeLbl: UILabel!
    @IBOutlet weak var helpfulImg: UIImageView!
    @IBOutlet weak var helpfulNumberLbl: UILabel!
    @IBOutlet weak var reviewTxt: UITextView!
    @IBOutlet weak var reviewImg: UIImageView?
    @IBOutlet weak var reviewStar1: UIImageView!
    @IBOutlet weak var reviewStar2: UIImageView!
    @IBOutlet weak var reviewStar3: UIImageView!
    @IBOutlet weak var reviewStar4: UIImageView!
    @IBOutlet weak var reviewStar5: UIImageView!
    
    var review: Review!
    var helpfulRef: FIRDatabaseReference!
    var helpful: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ReviewCell.helpfulTapped(_:)))
        tap.numberOfTapsRequired = 1
        helpfulImg.addGestureRecognizer(tap)
        helpfulImg.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ review: Review, img: UIImage?) {
        self.review = review
        self.usernameLbl.text = "\(review.username)"
        self.reviewDatetimeLbl.text = "\(Date(timeIntervalSince1970: review.reviewDatetime).dayMonthTime()!)"
        self.reviewTxt.text = "\(review.reviewText)"
        
        helpfulRef = DataService.ds.ref_current_user.child("helpful").child(review.reviewKey)
        
        helpfulRef.observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.value as? NSNull) != nil {
                self.helpful = false
                self.helpfulImg.image = UIImage(named: "thumbsup")
            } else {
                self.helpful = true
                self.helpfulImg.image = UIImage(named: "thumbsup-tapped")
            }
        })
        
        setHelpfulLbl()
        
        switch review.rating {
        case 1:
            reviewStar1.image = UIImage(named: "full-star")
            reviewStar2.image = UIImage(named: "empty-star")
            reviewStar3.image = UIImage(named: "empty-star")
            reviewStar4.image = UIImage(named: "empty-star")
            reviewStar5.image = UIImage(named: "empty-star")
        case 2:
            reviewStar1.image = UIImage(named: "full-star")
            reviewStar2.image = UIImage(named: "full-star")
            reviewStar3.image = UIImage(named: "empty-star")
            reviewStar4.image = UIImage(named: "empty-star")
            reviewStar5.image = UIImage(named: "empty-star")
        case 3:
            reviewStar1.image = UIImage(named: "full-star")
            reviewStar2.image = UIImage(named: "full-star")
            reviewStar3.image = UIImage(named: "full-star")
            reviewStar4.image = UIImage(named: "empty-star")
            reviewStar5.image = UIImage(named: "empty-star")
        case 4:
            reviewStar1.image = UIImage(named: "full-star")
            reviewStar2.image = UIImage(named: "full-star")
            reviewStar3.image = UIImage(named: "full-star")
            reviewStar4.image = UIImage(named: "full-star")
            reviewStar5.image = UIImage(named: "empty-star")
        case 5:
            reviewStar1.image = UIImage(named: "full-star")
            reviewStar2.image = UIImage(named: "full-star")
            reviewStar3.image = UIImage(named: "full-star")
            reviewStar4.image = UIImage(named: "full-star")
            reviewStar5.image = UIImage(named: "full-star")
        default:
            reviewStar1.image = UIImage(named: "empty-star")
            reviewStar2.image = UIImage(named: "empty-star")
            reviewStar3.image = UIImage(named: "empty-star")
            reviewStar4.image = UIImage(named: "empty-star")
            reviewStar5.image = UIImage(named: "empty-star")
        }
    }
    
    func setHelpfulLbl() {
        print(self.review.helpful)
        if self.review.helpful > 0 {
            if self.review.helpful == 1 {
                helpfulNumberLbl.text = "\(review.helpful) like"
            } else {
                helpfulNumberLbl.text = "\(review.helpful) likes"
            }
        } else {
            helpfulNumberLbl.text = "Was this review helpful?"
        }
    }
    
    @IBAction func helpfulTapped(_ sender: UITapGestureRecognizer) {
        
        if helpful == false {
            self.helpfulImg.image = UIImage(named: "thumbsup-tapped")
            self.review.adjustHelpfulCount(true)
            self.helpfulRef.setValue(true)
            self.helpful = true
        } else {
            self.helpfulImg.image = UIImage(named: "thumbsup")
            self.review.adjustHelpfulCount(false)
            self.helpfulRef.removeValue()
            self.helpful = false
        }
        
        setHelpfulLbl()
    }

}
