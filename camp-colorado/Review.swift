//
//  Review.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/19/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation

class Review {
    private var _username: String!
    private var _rating: Int!
    private var _reviewText: String!
    private var _imageUrl: String?
    private var _helpful: Int!
    
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
}