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
    @IBOutlet var label: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let id = API.Shared.firebaseRoot.authData?.uid {
            label.text = "Hey, \(id)"
        } else {
            label.text = "who dis"
        }
    }
    
    @IBAction func showProfile() {
        let canvasVC = storyboard!.instantiateViewControllerWithIdentifier("CanvasViewController") as! CanvasViewController
        canvasVC.canvas = API.Shared.firebaseRoot.childByAppendingPath("profiles/id123")
        navigationController!.pushViewController(canvasVC, animated: true)
    }
}
