//
//  DataService.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/17/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    static let ds = DataService()
    
    private var _ref = FIRDatabase.database().reference()
    private var _ref_reviews = FIRDatabase.database().referenceFromURL("https://ios-camp-colorado.firebaseio.com/reviews")
    
    var ref: FIRDatabaseReference {
        return _ref
    }
    
    var ref_reviews: FIRDatabaseReference {
        return _ref_reviews
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        ref.child("users").child(uid).setValue(user)
    }
}