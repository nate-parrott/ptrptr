//
//  API.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/14/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import Foundation
import Firebase

typealias Shape = [String: AnyObject]
typealias User = [String: AnyObject]

class API: NSObject {
    static let Shared = API()
    
    override init() {
        super.init()
        firebaseRoot.observeAuthEventWithBlock { [weak self] (let authOpt: FAuthData?) -> Void in
            self!.userPath = authOpt == nil ? nil : self!.firebaseRoot.childByAppendingPath("users").childByAppendingPath(authOpt!.uid)
        }
    }
    
    let firebaseRoot = Firebase(url: "https://ptrptr.firebaseio.com")
    
    // MARK: User
    private(set) var userPath: Firebase? {
        willSet(newVal) {
            userPath?.removeAllObservers()
            newVal?.observeSingleEventOfType(.Value, withBlock: { [weak self] (let snapshotOpt: FDataSnapshot?) -> Void in
                self!.userSnapshot = snapshotOpt
            })
        }
    }
    var _userPathChangeObserver: UInt?
    var userSnapshot: FDataSnapshot?
    
    // MARK: Assets
    let _servicesURL = "https://surfboard-services.appspot.com"
    
    func uploadAsset(data: NSData, contentType: String, callback: (url: NSURL?, error: NSError?) -> ()) {
        let urlComps = NSURLComponents(string: _servicesURL)!
        urlComps.queryItems = [NSURLQueryItem(name: "content_type", value: contentType)]
        let req = NSMutableURLRequest(URL: urlComps.URL!)
        req.HTTPMethod = "POST"
        req.HTTPBody = data
        let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { (dataOpt, responseOpt, errorOpt) -> Void in
            if let data = dataOpt,
                response = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                responseDict = response as? [String: AnyObject],
                urlString = responseDict["url"] as? String,
                url = NSURL(string: urlString) {
                    callback(url: url, error: nil)
            } else {
                callback(url: nil, error: errorOpt)
            }
        }
        task.resume()
    }
    
    // MARK: Onboarding
    func checkIfOnboardingComplete(callback: (result: Bool?) -> ()) {
        firebaseRoot.childByAppendingPath("users").childByAppendingPath(firebaseRoot.authData.uid).childByAppendingPath("onboarded").observeSingleEventOfType(.Value) { (let snapshotOpt: FDataSnapshot?) -> Void in
            if let snapshot = snapshotOpt {
                callback(result: snapshot.value as? Bool ?? false)
            } else {
                callback(result: nil)
            }
        }
    }
}
