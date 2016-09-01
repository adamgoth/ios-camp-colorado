//
//  CampsiteAnnotation.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/15/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation
import MapKit

class CampsiteAnnotation: MKPointAnnotation {
    var sitename: String
    var campsiteId: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var state: String
    var country: String
    var nearestTown: String
    var distanceToNearestTown: String
    var numberOfSites: String
    var phone: String
    var website: String
    var distanceFromUser: Int?
    
    init(sitename: String, campsiteId: Int, latitude: CLLocationDegrees, longitude: CLLocationDegrees, state: String, country: String, nearestTown: String, distanceToNearestTown: String, numberOfSites: String, phone: String, website: String, distanceFromUser: Int?) {
        self.sitename = sitename
        self.campsiteId = campsiteId
        self.latitude = latitude
        self.longitude = longitude
        self.state = state
        self.country = country
        self.nearestTown = nearestTown
        self.distanceToNearestTown = distanceToNearestTown
        self.numberOfSites = numberOfSites
        self.phone = phone
        self.website = website
        self.distanceFromUser = distanceFromUser
    }
}