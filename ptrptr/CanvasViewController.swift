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
                view.addSubview(n)
                n.translatesAutoresizingMaskIntoConstraints = false
                let a = topLayoutGuide.bottomAnchor.constraintEqualToAnchor(n.topAnchor)
                let b = view.centerXAnchor.constraintEqualToAnchor(n.centerXAnchor)
                let c = toolbar.topAnchor.constraintEqualToAnchor(n.bottomAnchor)
                view.addConstraints([a, b, c])
            }
        }
    }
}
