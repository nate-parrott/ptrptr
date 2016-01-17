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
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.setBackgroundImage(UIImage(named: "Black"), forToolbarPosition: .Any, barMetrics: .Default)
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
    @IBAction func insertShape() {
        let vc = InsertItemViewController()
        vc.parent = self
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBOutlet var drawingModeBar: DrawingEditModeBar!
    func startDrawing() {
        _editModeBarStack.append(drawingModeBar)
    }
    
    // MARK: Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let c = canvasView {
            _modalCanvasOverlay?.frame = c.frame
        }
    }
    
    // MARK: Edit modes
    var _editModeBarStack = [EditModeBar]() {
        willSet(newVal) {
            _currentEditModeBarTransitionAppearOnTop = newVal.count > _editModeBarStack.count
            _currentEditModeBar = newVal.last
        }
    }
    var _currentEditModeBarTransitionAppearOnTop = false
    var _currentEditModeBar: EditModeBar? {
        willSet(newVal) {
            let height: CGFloat = 50
            
            if let bar = newVal {
                bar.canvasVC = self
                _modalCanvasOverlay = bar.modalCanvasOverlay()
                
                bar.translatesAutoresizingMaskIntoConstraints = true
                if !_currentEditModeBarTransitionAppearOnTop, let old = _currentEditModeBar {
                    view.insertSubview(bar, belowSubview: old)
                } else {
                    view.addSubview(bar)
                }
                bar.frame = CGRectMake(0, view.bounds.size.height, view.bounds.size.width, height)
                bar.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
                
                UIView.animateWithDuration(0.15, delay: 0, options: [.CurveEaseOut], animations: { () -> Void in
                    bar.frame = CGRectMake(0, self.view.bounds.size.height - height, bar.frame.size.width, height)
                    }, completion: { (let completed) -> Void in
                        
                })
            }
            
            if let old = _currentEditModeBar {
                UIView.animateWithDuration(0.15, delay: 0, options: [.CurveEaseIn], animations: { () -> Void in
                    old.frame = CGRectMake(0, self.view.bounds.size.height, old.frame.size.width, old.frame.size.height)
                    }, completion: { (let completed) -> Void in
                        old.removeFromSuperview()
                })
            }
        }
    }
    var _modalCanvasOverlay: UIView? {
        willSet(newVal) {
            if let old = _modalCanvasOverlay {
                old.removeFromSuperview()
            }
            if let new = newVal {
                if let canvas = canvasView {
                    view.insertSubview(new, aboveSubview: canvas)
                } else {
                    view.insertSubview(new, atIndex: 0)
                }
            }
        }
    }
    
    @IBAction func popEditMode() {
        var stack = _editModeBarStack
        stack.removeLast()
        _editModeBarStack = stack
    }
}
