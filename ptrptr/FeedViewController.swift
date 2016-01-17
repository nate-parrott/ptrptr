//
//  FeedViewController.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController {
    
    @IBOutlet var collection: ViewCollection!
    
    // MARK: Lifecycle:
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        API.Shared.checkIfOnboardingComplete { (resultOpt) -> () in
            if let result = resultOpt {
                if !result {
                    self.presentViewController(self.storyboard!.instantiateViewControllerWithIdentifier("OnboardingViewController"), animated: true, completion: nil)
                }
            }
        }
    }
    
    var _friends: Firebase!
    var _friendsList = [String: AnyObject]() {
        didSet {
            let selfUid = API.Shared.firebaseRoot.authData.uid
            let friends = [selfUid] + _friendsList.values.filter({ ($0 as? String) != nil }).map({ $0 as! String })
            collection.models = friends
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup collection:
        collection.viewFunction = {
            (model: AnyObject, existingView: UIView?) -> UIView in
            let cell = (existingView as? FeedCellView) ?? FeedCellView()
            cell.canvas = API.Shared.firebaseRoot.childByAppendingPath("profiles").childByAppendingPath(model as! String)
            return cell
        }
        collection.onSelectedModel = {
            [weak self] (model: AnyObject) in
            self!.showFriendProfile(model as! String)
        }
        // start observing friends:
        _friends = API.Shared.userPath!.childByAppendingPath("friends")
        _friends.observeEventType(.Value) { [weak self] (snapshotOpt: FDataSnapshot?) -> Void in
            if let val = snapshotOpt?.value as? [String: AnyObject] {
                self!._friendsList = val
            } else {
                self!._friendsList = [String: AnyObject]()
            }
        }
    }
    
    deinit {
        _friends.removeAllObservers()
    }
    
    // MARK: Nav
    
    func showFriendProfile(id: String) {
        let canvasVC = storyboard!.instantiateViewControllerWithIdentifier("CanvasViewController") as! CanvasViewController
        canvasVC.canvas = API.Shared.firebaseRoot.childByAppendingPath("profiles").childByAppendingPath(id)
        navigationController!.pushViewController(canvasVC, animated: true)
    }
    
    // MARK: Appearance
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = collection.bounds.size.width
        let height = width * API.Shared.aspectRatioForFeedZone
        let layout = collection.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collection.collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length + 15, 0)
        layout.itemSize = CGSizeMake(width, height)
        layout.minimumLineSpacing = 15
    }
}
