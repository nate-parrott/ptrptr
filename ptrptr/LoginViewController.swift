//
//  LoginViewController.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var loading = false {
        didSet {
            if loading {
                loader.startAnimating()
            } else {
                loader.stopAnimating()
            }
            view.userInteractionEnabled = !loading
        }
    }
    
    @IBOutlet var loader: UIActivityIndicatorView!
    
    @IBAction func logIn() {
        FBSDKLoginManager().logInWithReadPermissions(["email"], fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError?) -> Void in
            if let err = error {
                print("Facebook: \(err)")
            } else if result.isCancelled {
                print("Cancalled")
            } else {
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                API.Shared.firebaseRoot.authWithOAuthProvider("facebook", token: token, withCompletionBlock: { (errorOpt: NSError?, authOpt: FAuthData?) -> Void in
                    if let err = errorOpt {
                        print("Firebase: \(err)")
                    } else if authOpt != nil {
                        print("auth'd successfully!")
                    }
                })
            }
        }
    }
}
