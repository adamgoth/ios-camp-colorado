//
//  Campsite.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/9/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

class Campsite {
    private var _campsiteId: Int!
    private var _sitename: String!
    private var _latitude: CLLocationDegrees!
    private var _longitude: CLLocationDegrees!
    
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
    
    init(campsiteId: Int, sitename: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self._campsiteId = campsiteId
        self._sitename = sitename
        self._latitude = latitude
        self._longitude = longitude
    }
}