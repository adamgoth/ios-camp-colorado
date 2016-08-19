//
//  CampsiteDetailViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/15/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import MapKit

class CampsiteDetailViewController: UIViewController {
    
    @IBOutlet weak var sitenameLbl: UILabel!
    @IBOutlet weak var distanceToTownLbl: UILabel!
    @IBOutlet weak var nearestTownLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var numberOfSitesLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    
    var annotation: CampsiteAnnotation!

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
    }

    @IBAction func backButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
