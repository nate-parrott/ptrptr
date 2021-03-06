//
//  AppDelegate.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //API.Shared.firebaseRoot.unauth()
        //return true
        _resubscribeToFirebaseAuthEvents()
        
        return true
    }
    
    var _firebaseAuthEventHandle: UInt?
    func _resubscribeToFirebaseAuthEvents() {
        if let handle = _firebaseAuthEventHandle {
            API.Shared.firebaseRoot.removeAuthEventObserverWithHandle(handle)
        }
        _firebaseAuthEventHandle = API.Shared.firebaseRoot.observeAuthEventWithBlock { (authData: FAuthData?) -> Void in
            API.Shared._authUpdated()
            if authData == nil {
                let existingLoginDialogOpt = (self.window?.rootViewController as? LoginViewController)
                let loginWindowAlreadyPresented = (existingLoginDialogOpt != nil)
                if !loginWindowAlreadyPresented {
                    // present login VC, but first, dismiss all modals:
                    while let modal = self.window?.rootViewController?.presentingViewController {
                        modal.dismissViewControllerAnimated(false, completion: nil)
                    }
                    
                    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
                    self.window!.rootViewController = loginVC
                    
                    delay(0.5, closure: { () -> () in
                        self._resubscribeToFirebaseAuthEvents()
                    })
                }
            } else {
                // we're logged in:
                let existingFeedOpt = (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? FeedViewController
                if existingFeedOpt == nil {
                    self.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FeedNav")
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Window
    
    var _window: CMWindow?
    var window: UIWindow? {
        get {
            if _window == nil {
                _window = CMWindow(frame: UIScreen.mainScreen().bounds)
            }
            return _window
        }
        set (val) {
            // do nothing?
        }
    }

}

