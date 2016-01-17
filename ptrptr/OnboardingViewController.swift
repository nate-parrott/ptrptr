//
//  OnboardingViewController.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/17/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class OnboardingViewController: UIViewController {
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var name: UITextField!
    @IBOutlet var hue: HueSlider!
    @IBOutlet var formContainer: UIView!
    @IBOutlet var doneButton: UIButton!
    
    @IBAction func done() {
        // save:
        user.childByAppendingPath("name").setValue(name.text)
        let (r,g,b,a) = UIColor(hue: hue.hue, saturation: 1, brightness: 1, alpha: 1).rgba
        user.childByAppendingPath("color").setValue([r,g,b,a])
        user.childByAppendingPath("onboarded").setValue(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        srand(UInt32(time(nil)))
        hue.hue = CGFloat(random() % 1000) / 1000.0
        prepopulate()
    }
    
    var loading = false {
        didSet {
            let a: CGFloat = loading ? 0.5 : 1
            doneButton.alpha = a
            formContainer.alpha = a
            
            view.userInteractionEnabled = !loading
            if loading {
                loader.startAnimating()
            } else {
                loader.stopAnimating()
            }
        }
    }
    
    // MARK: Fetching data
    var _firebaseDone = false
    var _nameFromFirebase: String?
    var _facebookDone = false
    var _nameFromFacebook: String?
    func prepopulate() {
        loading = true
        _firebaseDone = false
        _facebookDone = false
        _fetchFirebase()
        _fetchFacebook()
    }
    func _fetchFirebase() {
        user.observeSingleEventOfType(.Value) { (snapshotOpt: FDataSnapshot?) -> Void in
            if let snapshot = snapshotOpt, let dict = snapshot.value as? [String: AnyObject] {
                if let name = dict["name"] as? String {
                    self._nameFromFirebase = name
                }
                if let color = dict["color"] as? [CGFloat] where color.count == 4 {
                    self.hue.hue = UIColor(red: color[0], green: color[1], blue: color[2], alpha: color[3]).hsva.0
                }
            }
            self._firebaseDone = true
            self._checkDonePrepopulating()
        }
        
        
    }
    func _fetchFacebook() {
        // get some info from facebook:
        if FBSDKAccessToken.currentAccessToken() != nil {
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,name,first_name"])
            req.startWithCompletionHandler({ (let connOpt: FBSDKGraphRequestConnection?, let objectOpt: AnyObject?, let errorOpt: NSError?) -> Void in
                if let dict = objectOpt as? [String: AnyObject] {
                    if let name = dict["name"] as? String {
                        self._nameFromFacebook = name
                    }
                }
                self._facebookDone = true
                self._checkDonePrepopulating()
            })
        } else {
            _facebookDone = true
            _checkDonePrepopulating()
        }
    }
    func _checkDonePrepopulating() {
        if _facebookDone && _firebaseDone {
            name.text = (_nameFromFirebase ?? _nameFromFacebook ?? "Me")
            loading = false
        }
    }
    var user: Firebase {
        get {
            return API.Shared.firebaseRoot.childByAppendingPath("users").childByAppendingPath(API.Shared.firebaseRoot.authData.uid)
        }
    }
}
