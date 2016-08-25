//
//  AccountViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/24/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var usernameLbl: UILabel?
    
    var username: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = username {
            usernameLbl?.text = user
        }
        
        DataService.ds.ref_current_user.child("username").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let name = snapshot.value as? String {
                self.username = name
            }
        })
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
