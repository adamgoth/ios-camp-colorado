//
//  LoginViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/16/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var signInEmail: UITextField!
    @IBOutlet weak var signInPassword: UITextField!
    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var signUpUsername: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signInPressed() {
        if let email = signInEmail.text where email != "", let pwd = signInPassword.text where pwd != "" {
            FIRAuth.auth()?.signInWithEmail(email, password: pwd) { (user, error) in
                if error != nil {
                    print(error)
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                    print("User logged in")
                }
                self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
            }
        } else {
            showErrorAlert("Email and Password Required", message: "You must enter an email and password")
        }
    }
    
    @IBAction func createAccountPressed() {
        if let email = signUpEmail.text where email != "", let pwd = signUpPassword.text where pwd != "", let username = signUpUsername.text where username != "" {
            FIRAuth.auth()?.createUserWithEmail(email, password: pwd) { (user, error) in
                if error != nil {
                    print(error)
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                    FIRAuth.auth()?.signInWithEmail(email, password: pwd) { (user, error) in
                        print("Account created, user signed in")
                        let userData = ["provider": user!.providerID, "username": username]
                        DataService.ds.createFirebaseUser(user!.uid, user: userData)
                    }
                    self.performSegueWithIdentifier(SEGUE_LOGIN, sender: nil)
                }
            }
        } else {
            showErrorAlert("Could Not Create Account", message: "No soup for you!")
        }
    }
    

}
