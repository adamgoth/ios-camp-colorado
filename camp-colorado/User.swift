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
    
    var username: String {
        return _username
    }
    
    var userKey: String {
        return _userKey
    }
    
    var userCreatedAt: String {
        return _userCreatedAt
    }
    
    init(username: String, userCreatedAt: String) {
        self._username = username
        self._userCreatedAt = userCreatedAt
    }
}
