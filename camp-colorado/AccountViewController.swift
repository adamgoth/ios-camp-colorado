//
//  AccountViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/24/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLbl?.text = user.username
        
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
