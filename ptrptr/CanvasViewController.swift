//
//  CanvasViewController.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class CanvasViewController: UIViewController {
    
    var canvas: Firebase! {
        didSet {
            canvasView = CanvasView(canvas: canvas)
        }
    }
    
    // MARK: Views
    @IBOutlet var toolbar: UIToolbar!
    
    var canvasView: CanvasView? {
        willSet(new) {
            if let old = canvasView {
                old.removeFromSuperview()
            }
            if let n = new {
                view.insertSubview(n, atIndex: 0)
                n.translatesAutoresizingMaskIntoConstraints = false
                let a = topLayoutGuide.bottomAnchor.constraintEqualToAnchor(n.topAnchor)
                let b = view.centerXAnchor.constraintEqualToAnchor(n.centerXAnchor)
                let c = view.widthAnchor.constraintEqualToAnchor(n.widthAnchor)
                let d = toolbar.topAnchor.constraintEqualToAnchor(n.bottomAnchor)
                view.addConstraints([a, b, c, d])
            }
        }
    }
    
    // MARK: Actions
}
