//
//  Review.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/19/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation
import Firebase

class Review {
    fileprivate var _campsiteId: Int!
    fileprivate var _reviewKey: String!
    fileprivate var _reviewDatetime: Double!
    fileprivate var _username: String!
    fileprivate var _rating: Int!
    fileprivate var _reviewText: String!
    fileprivate var _imageUrl: String?
    fileprivate var _helpful: Int!
    
    fileprivate var _reviewRef: FIRDatabaseReference!
    
    var campsiteId: Int {
        return _campsiteId
    }
    
    var reviewKey: String {
        return _reviewKey
    }
    
    var reviewDatetime: Double {
        return _reviewDatetime
    }
    
    var username: String {
        return _username
    }
    
    var rating: Int {
        return _rating
    }
    
    var reviewText: String {
        return _reviewText
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var helpful: Int {
        return _helpful
    }
    
    init(username: String, rating: Int, reviewText: String, imageUrl: String? = nil) {
        self._username = username
        self._rating = rating
        self._reviewText = reviewText
        self._imageUrl = imageUrl
    }
    
    init(reviewKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._reviewKey = reviewKey
        
        if let reviewDatetime = dictionary["reviewDatetime"] as? Double {
            self._reviewDatetime = reviewDatetime
        }
        
        if let campsiteId = dictionary["campsiteId"] as? Int {
            self._campsiteId = campsiteId
        }
        
        if let username = dictionary["username"] as? String {
            self._username = username
        }
        
        if let rating = dictionary["rating"] as? Int {
            self._rating = rating
        }
        
        if let reviewText = dictionary["reviewText"] as? String {
            self._reviewText = reviewText
        }
        
        if let helpful = dictionary["helpful"] as? Int {
            self._helpful = helpful
        }
        
        self._reviewRef = DataService.ds.ref_reviews.child("\(self._campsiteId!)").child(self._reviewKey)
    }
    
    func adjustHelpfulCount(_ addHelpful: Bool) {
        if addHelpful {
            _helpful = _helpful + 1
        } else {
            _helpful = _helpful - 1
        }
        
        _reviewRef.child("helpful").setValue(_helpful)
    }
}
