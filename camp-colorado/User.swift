//
//  User.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/28/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation

class User {
    private var _username: String!
    private var _userKey: String!
    
    var username: String {
        return _username
    }
    
    var userKey: String {
        return _userKey
    }
    
    init(username: String) {
        self._username = username
    }
}