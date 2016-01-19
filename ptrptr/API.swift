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
            newVal?.observeEventType(.Value, withBlock: { [weak self] (let snapshotOpt: FDataSnapshot?) -> Void in
                self!.userSnapshot = snapshotOpt
            })
        }
    }
    var _userPathChangeObserver: UInt?
    var userSnapshot: FDataSnapshot?
    var user: User! {
        get {
            if let snapshot = userSnapshot, let user = snapshot.value as? User {
                return user
            } else {
                return nil
            }
        }
    }
    var userColor: [CGFloat]! {
        get {
            return user?["color"] as? [CGFloat]
        }
    }
    var uid: String! {
        get {
            return firebaseRoot.authData?.uid
        }
    }
    
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
    
    // MARK: Canvas
    let aspectRatioForFeedZone: CGFloat = 0.3
    
    func getJsonForNewCanvas(isUserProfile: Bool) -> [String: AnyObject] {
        var size = UIScreen.mainScreen().bounds.size
        size.height -= 44
        
        var zones = [String: AnyObject]()
        let margin: CGFloat = 0
        if isUserProfile {
            let feedWidth = (size.width - margin*2)
            let feedHeight = feedWidth * aspectRatioForFeedZone
            zones["feed"] = [margin, margin, feedWidth, feedHeight]
            zones["thumbnail"] = [margin, margin, feedHeight, feedHeight]
        } else {
            let thumbSize = size.width * 0.26
            zones["thumbnail"] = [margin, margin, thumbSize, thumbSize]
        }
        
        return [
            "width": size.width,
            "height": size.height,
            "owner": firebaseRoot.authData.uid,
            "zones": zones,
            "modified": timestampString()
        ]
    }
    
    func getJsonForNewShape(type: String, userIsOwner: Bool) -> [String: AnyObject] {
        var json = [String: AnyObject]()
        json["type"] = type
        if let user = userSnapshot?.value as? [String: AnyObject],
            let color = user["color"] as? [CGFloat],
            let name = user["name"] as? String,
            let id = firebaseRoot.authData?.uid {
            json["author"] = ["color": color, "name": name, "id": id]
        } else {
            print("Tried creating shape, but no user data available for self")
        }
        json["z"] = userIsOwner ? 10000 : 1
        return json
    }
    
    // MARK: Utils
    func timestampString() -> String {
        return "\(NSDate().timeIntervalSince1970)"
    }
}
