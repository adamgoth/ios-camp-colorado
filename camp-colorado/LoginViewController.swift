//
//  LoginViewController.swift
//  camp-colorado
//
//  Created by Adam Goth on 8/16/16.
//  Copyright © 2016 Adam Goth. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signInEmail: UITextField!
    @IBOutlet weak var signInPassword: UITextField!
    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var signUpUsername: UITextField!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var createAccountView: UIView!
    @IBOutlet weak var backToSignInView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInEmail.delegate = self
        signInPassword.delegate = self
        signUpEmail.delegate = self
        signUpPassword.delegate = self
        signUpUsername.delegate = self
        
        signInEmail.returnKeyType = UIReturnKeyType.done
        signInPassword.returnKeyType = UIReturnKeyType.done
        signUpEmail.returnKeyType = UIReturnKeyType.done
        signUpPassword.returnKeyType = UIReturnKeyType.done
        signUpUsername.returnKeyType = UIReturnKeyType.done
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            self.performSegue(withIdentifier: SEGUE_LOGIN, sender: nil)
        }
    }
    
    func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @IBAction func signInPressed() {
        if let email = signInEmail.text , email != "", let pwd = signInPassword.text , pwd != "" {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd) { (user, error) in
                if error != nil {
                    if String(describing: error).range(of: "17009") != nil {
                        self.showErrorAlert("Invalid Password", message: "Please try again")
                    }
                    print(error)
                } else {
                    UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                    print("User logged in")
                    self.performSegue(withIdentifier: SEGUE_LOGIN, sender: nil)
                }
            }
        } else {
            showErrorAlert("Email and Password Required", message: "You must enter an email and password")
        }
    }
    
    @IBAction func signUpPressed() {
        signInView.isHidden = true
        signUpView.isHidden = true
        createAccountView.isHidden = false
        backToSignInView.isHidden = false
    }
    
    @IBAction func backToSignInPressed() {
        signInView.isHidden = false
        signUpView.isHidden = false
        createAccountView.isHidden = true
        backToSignInView.isHidden = true
    }
    
    @IBAction func createAccountPressed() {
        if let email = signUpEmail.text , email != "", let pwd = signUpPassword.text , pwd != "", let username = signUpUsername.text , username != "" {
            FIRAuth.auth()?.createUser(withEmail: email, password: pwd) { (user, error) in
                if error != nil {
                    if String(describing: error).range(of: "17007") != nil {
                        self.showErrorAlert("Email In Use", message: "This email address is already in use")
                    } else if String(describing: error).range(of: "17008") != nil {
                        self.showErrorAlert("Invalid Email Address", message: "This does not appear to be a valid email address format")
                    } else if String(describing: error).range(of: "17026") != nil {
                        self.showErrorAlert("Invalid Password", message: "Your password must be six characters long or more")
                    }
                    print(error)
                } else {
                    let usernameQuery = DataService.ds.ref_users.queryOrdered(byChild: "username").queryEqual(toValue: username)
                    usernameQuery.observe(FIRDataEventType.value, with: { (snapshot) in
                        if snapshot.value as? NSNull != nil {
                            FIRAuth.auth()?.signIn(withEmail: email, password: pwd) { (user, error) in
                                if error != nil {
                                    print(error)
                                } else {
                                    print("Account created, user signed in")
                                    let userData = ["provider": user!.providerID, "username": username, "userCreatedAt": "\(Date().timeIntervalSince1970)"]
                                    DataService.ds.createFirebaseUser(user!.uid, user: userData as Dictionary<String, AnyObject>)
                                    UserDefaults.standard.setValue(user!.uid, forKey: KEY_UID)
                                    self.performSegue(withIdentifier: SEGUE_LOGIN, sender: nil)
                                }
                            }
                        } else {
                            self.showErrorAlert("Username Unavailable", message: "Please select a different username")
                        }
                    })
                }
            }
        } else {
            showErrorAlert("Could Not Create Account", message: "Did you fill out all fields?")
        }
    }
    

}
