//
//  CampsiteCell.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/30/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit

class CampsiteCell: UITableViewCell {
    
    @IBOutlet weak var sitenameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    var campsite: Campsite!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ campsite: Campsite) {
        self.campsite = campsite
        self.sitenameLbl.text = campsite.sitename
        if campsite.distanceFromUser != nil {
            self.distanceLbl.text = "\(campsite.distanceFromUser!) miles away"
        } else {
            self.distanceLbl.text = ""
        }
        
    }

}
