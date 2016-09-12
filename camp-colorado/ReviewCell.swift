//
//  ReviewCell.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/19/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var reviewDatetimeLbl: UILabel!
    @IBOutlet weak var helpfulImg: UIImageView!
    @IBOutlet weak var reviewTxt: UITextView!
    @IBOutlet weak var reviewImg: UIImageView?
    @IBOutlet weak var reviewStar1: UIImageView!
    @IBOutlet weak var reviewStar2: UIImageView!
    @IBOutlet weak var reviewStar3: UIImageView!
    @IBOutlet weak var reviewStar4: UIImageView!
    @IBOutlet weak var reviewStar5: UIImageView!
    
    var review: Review!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(review: Review, img: UIImage?) {
        self.review = review
        self.usernameLbl.text = "\(review.username)"
        self.reviewDatetimeLbl.text = "\(NSDate(timeIntervalSince1970: review.reviewDatetime).dayMonthTime()!)"
        self.reviewTxt.text = "\(review.reviewText)"
        
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

}
