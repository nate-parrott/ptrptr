//
//  Canvas.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

@objc protocol CanvasViewDelegate {
    
}

class CanvasView: ShapesView, UIGestureRecognizerDelegate {
    // MARK: Lifecycle
    init(canvas: Firebase) {
        self.canvas = canvas
        super.init(frame: CGRectZero)
        _valueObserverToken = canvas.observeEventType(.Value) { [weak self] (snapshot: FDataSnapshot?) -> Void in
            self!._value = snapshot?.value as? [String: AnyObject]
        }
        _setupGestures()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        self.canvas.removeObserverWithHandle(_valueObserverToken!)
    }
    let canvas: Firebase!
    var transactionStack: CMTransactionStack!
    var _valueObserverToken: UInt?
    var _value: [String: AnyObject]? {
        didSet {
            _needsRender = true
            if let v = _value, width = v["width"] as? CGFloat, height = v["height"] as? CGFloat {
                coordinateSpace.size = CGSizeMake(width, height)
            }
            
            if let v = _value, let ownerID = v["owner"] as? String, let uid = API.Shared.uid {
                userIsOwner = (ownerID == uid)
            }
        }
    }
    var userIsOwner: Bool!
    
    // MARK: Delegate
    @IBOutlet var delegate: CanvasViewDelegate!
    
    // MARK: Render loop
    var _renderingActive = false {
        didSet {
            if _renderingActive && _displayLink == nil {
                _displayLink = CADisplayLink(target: self, selector: "_displayLinkCallback:")
                _displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
            } else if !_renderingActive && _displayLink != nil {
                _displayLink!.invalidate()
                _displayLink = nil
            }
        }
    }
    var _needsRender = false
    var _displayLink: CADisplayLink?
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        _renderingActive = (newWindow != nil)
    }
    
    func _displayLinkCallback(sender: CADisplayLink) {
        if _needsRender {
            if let shapeDict = _value?["shapes"] as? [String: Shape] {
                render(Shapes.convertShapeDictToArray(shapeDict))
                let selectedShapeViews = selectionIDs.map({ self._viewsByID[$0] }).filter({ $0 != nil }).map({ $0! })
                _drawSelectionIndicators(selectedShapeViews)
                _needsRender = false
            }
        }
    }
    
    // MARK: Selection
    var selectionIDs = [String]() {
        didSet {
            _needsRender = true
        }
    }
    var _selectionIndicatorViews = [SelectionIndicatorView]()
    func _drawSelectionIndicators(views: [ShapeView]) {
        while _selectionIndicatorViews.count < views.count {
            _selectionIndicatorViews.append(SelectionIndicatorView())
            addSubview(_selectionIndicatorViews.last!)
        }
        while _selectionIndicatorViews.count > views.count {
            _selectionIndicatorViews.last!.removeFromSuperview()
            _selectionIndicatorViews.removeLast()
        }
        for (view, indicator) in zip(views, _selectionIndicatorViews) {
            indicator.superview!.bringSubviewToFront(indicator)
            let (rotation, scale) = view.transformation
            indicator.bounds = CGRectMake(0, 0, view.bounds.size.width * scale, view.bounds.size.height * scale)
            indicator.transform = CGAffineTransformMakeRotation(rotation)
            indicator.center = view.center
        }
    }
    
    func authorForShape(id: String) -> [String: AnyObject]? {
        if let shapes = _value?["shapes"] as? [String: AnyObject],
            let shape = shapes[id] as? Shape,
            let author = shape["author"] as? [String: AnyObject] {
                return author
        } else {
            return nil
        }
    }
    
    // MARK: Moving
    
    var _movingTransaction: _MovingTransaction?
    
    var _shapeToMove: String? {
        return selectionIDs.filter({ self.canMoveShapeWithID($0) }).first
    }
    
    func canMoveShapeWithID(id: String) -> Bool {
        if let isOwner = userIsOwner where isOwner {
            return true
        } else {
            if let author = authorForShape(id), let authorID = author["id"] as? String {
                return authorID == API.Shared.uid
            } else {
                return false
            }
        }
    }
}
