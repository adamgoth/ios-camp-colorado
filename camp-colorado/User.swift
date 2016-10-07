//
//  User.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/28/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation

class User {
    fileprivate var _username: String!
    fileprivate var _userKey: String!
    fileprivate var _userCreatedAt: String!
    fileprivate var _reviewsCount: Int!
    
    var username: String {
        return _username
    }
    
    var userKey: String {
        return _userKey
    }
    
    var userCreatedAt: String {
        return _userCreatedAt
    }
    
    var reviewsCount: Int {
        get {
            return _reviewsCount
        }
        set {
            _reviewsCount = newValue
        }
    }
    
    init(username: String, userCreatedAt: String, reviewsCount: Int) {
        self._username = username
        self._userCreatedAt = userCreatedAt
        self._reviewsCount = reviewsCount
    }
}
