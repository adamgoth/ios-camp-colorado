//
//  Constants.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/17/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation

//keys
let KEY_UID = "uid"

//segues
let SEGUE_LOGIN = "login"
let SEGUE_SHOW_ACCOUNT = "showAccount"
let SEGUE_CAMPSITE_DETAIL = "showCampsiteDetail"
let SEGUE_SHOW_ALL_REVIEWS = "showAllReviews"

extension NSDate {
    func dayMonthTime() -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, h:mm a"
        return dateFormatter.stringFromDate(self)
    }
    
    func dayMonthYear() -> String? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, y"
        return dateFormatter.stringFromDate(self)
    }
}