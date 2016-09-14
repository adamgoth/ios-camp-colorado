//
//  Campsite.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/9/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation
import MapKit

class Campsite {
    fileprivate var _campsiteId: Int!
    fileprivate var _sitename: String!
    fileprivate var _latitude: CLLocationDegrees!
    fileprivate var _longitude: CLLocationDegrees!
    fileprivate var _state: String!
    fileprivate var _country: String!
    fileprivate var _nearestTown: String!
    fileprivate var _distanceToNearestTown: String!
    fileprivate var _numberOfSites: String!
    fileprivate var _phone: String!
    fileprivate var _website: String!
    fileprivate var _distanceFromUser: Int?
    
    var campsiteId: Int {
        return _campsiteId
    }
    
    var sitename: String {
        return _sitename
    }
    
    var latitude: CLLocationDegrees {
        return _latitude
    }
    
    var longitude: CLLocationDegrees {
        return _longitude
    }
    
    var state: String {
        return _state
    }
    
    var country: String {
        return _country
    }
    
    var nearestTown: String {
        if _nearestTown == nil {
            _nearestTown = ""
        }
        return _nearestTown
    }
    
    var distanceToNearestTown: String {
        if _distanceToNearestTown == nil {
            _distanceToNearestTown = ""
        }
        return _distanceToNearestTown
    }
    
    var numberOfSites: String {
        if _numberOfSites == nil {
            _numberOfSites = ""
        }
        return _numberOfSites
    }
    
    var phone: String {
        if _phone == nil {
            _phone = ""
        }
        return _phone
    }
    
    var website: String {
        if _website == nil {
            _website = ""
        }
        return _website
    }
    
    var distanceFromUser: Int? {
        get {
            return _distanceFromUser
        }
        set {
            _distanceFromUser = newValue
        }
    }
    
    init(campsiteId: Int, sitename: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, state: String, country: String, nearestTown: String, distanceToNearestTown: String, numberOfSites: String, phone: String, website: String) {
        self._campsiteId = campsiteId
        self._sitename = sitename
        self._latitude = latitude
        self._longitude = longitude
        self._state = state
        self._country = country
        self._nearestTown = nearestTown
        self._distanceToNearestTown = distanceToNearestTown
        self._numberOfSites = numberOfSites
        self._phone = phone
        self._website = website
    }
}
