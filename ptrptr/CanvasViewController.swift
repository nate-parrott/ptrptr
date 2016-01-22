//
//  CanvasViewController.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class CanvasViewController: UIViewController, CanvasViewDelegate {
    
    var canvas: Firebase! {
        didSet {
            canvasView = CanvasView(canvas: canvas)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        toolbar.setBackgroundImage(UIImage(named: "Black"), forToolbarPosition: .Any, barMetrics: .Default)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_transactionHappened:", name: CMTransactionStackDidExecuteTransactionNotification, object: transactionStack)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_mediaCacheUpdated:", name: MediaCache.MediaCacheDidLoadMediaNotification, object: MediaCache.Shared)
        API.Shared.userPath!.childByAppendingPath("color").observeSingleEventOfType(.Value) { [weak self] (let snapshotOpt: FDataSnapshot?) -> Void in
            if let color = snapshotOpt?.value as? [CGFloat] where color.count == 4 {
                self?.addButton.backgroundColor = UIColor(red: color[0], green: color[1], blue: color[2], alpha: color[3])
            }
        }
    }
    
    @IBOutlet var addButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func back() {
        navigationController!.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        delay(MediaCache.Shared._maxImageAge + 1) { () -> () in
            MediaCache.Shared.deleteStaleImages()
        }
    }
    
    // MARK: Views
    @IBOutlet var toolbar: UIToolbar!
    
    var canvasView: CanvasView? {
        willSet(new) {
            if let old = canvasView {
                old.removeFromSuperview()
                old.delegate = nil
            }
            if let n = new {
                n.transactionStack = transactionStack
                view.insertSubview(n, atIndex: 0)
                n.translatesAutoresizingMaskIntoConstraints = false
                let a = topLayoutGuide.bottomAnchor.constraintEqualToAnchor(n.topAnchor)
                let b = view.centerXAnchor.constraintEqualToAnchor(n.centerXAnchor)
                let c = view.widthAnchor.constraintEqualToAnchor(n.widthAnchor)
                let d = toolbar.topAnchor.constraintEqualToAnchor(n.bottomAnchor)
                view.addConstraints([a, b, c, d])
                n.delegate = self
            }
        }
    }
    
    // MARK: Canvas delegate
    func canvasView(view: CanvasView, selectionChanged: Set<String>) {
        if let id = view.selectionIDs.first, let shapeView = view._viewsByID[id] {
            _shapeOptionsBar.shapeView = shapeView
            _shapeOptionsBar.canvasVC = self
            _editModeBarStack = [_shapeOptionsBar]
        } else {
            while _editModeBarStack.indexOf(_shapeOptionsBar) != nil {
                _editModeBarStack.removeLast()
            }
        }
    }
    
    func canvasViewInitialLoadCompleted(view: CanvasView) {
        
    }
    
    // MARK: Actions
    @IBAction func insertShape() {
        if let loaded = canvasView?.initialLoadCompleted where loaded {
            let vc = InsertItemViewController()
            vc.parent = self
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet var drawingModeBar: DrawingEditModeBar!
    func startDrawing() {
        _editModeBarStack.append(drawingModeBar)
    }
    
    // MARK: Transactions
    let transactionStack = CMTransactionStack()
    func _transactionHappened(notif: NSNotification) {
        canvas.childByAppendingPath("modified").setValue(API.Shared.timestampString())
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
    var _shapeOptionsBar = ShapeOptionsBar()
    var _currentEditModeBarTransitionAppearOnTop = false
    var _currentEditModeBar: EditModeBar? {
        willSet(newVal) {
            if newVal === _currentEditModeBar { return }
            
            let height: CGFloat = 50
            
            _modalCanvasOverlay = newVal?.modalCanvasOverlay()
            
            if let bar = newVal {
                bar.canvasVC = self
                
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
    
    // MARK: Misc.
    func _mediaCacheUpdated(notif: NSNotification) {
        canvasView?._needsRender = true
    }
}
