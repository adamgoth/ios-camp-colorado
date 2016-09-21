//
//  AccountViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/24/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var signUpDateLbl: UILabel!
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLbl?.text = user.username
        signUpDateLbl?.text = "\(Date(timeIntervalSince1970: Double(user.userCreatedAt)!).dayMonthYear()!)"
        
    }
    
    @IBAction func signOutPressed(_ sender: AnyObject) {
        do {
            try FIRAuth.auth()?.signOut()
            UserDefaults.standard.removeObject(forKey: KEY_UID)
            self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            print("Signout successful")
        } catch {
            print("Signout unsuccessful")
        }
        
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
