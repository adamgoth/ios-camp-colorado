//
//  Review.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/19/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation

class Review {
    private var _campsiteId: Int!
    private var _reviewKey: String!
    private var _username: String!
    private var _rating: Int!
    private var _reviewText: String!
    private var _imageUrl: String?
    private var _helpful: Int!
    
    var campsiteId: Int {
        return _campsiteId
    }
    
    var reviewKey: String {
        return _reviewKey
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
    }
}