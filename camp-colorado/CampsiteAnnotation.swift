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
    
    init(sitename: String, campsiteId: Int) {
        self.sitename = sitename
        self.campsiteId = campsiteId
    }
}