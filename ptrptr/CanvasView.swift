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
    func canvasView(view: CanvasView, selectionChanged: Set<String>)
    func canvasViewInitialLoadCompleted(view: CanvasView)
}

class CanvasView: ShapesView, UIGestureRecognizerDelegate {
    // MARK: Lifecycle
    init(canvas: Firebase) {
        self.canvas = canvas
        super.init(frame: CGRectZero)
        _valueObserverToken = canvas.observeEventType(.Value) { [weak self] (snapshot: FDataSnapshot?) -> Void in
            self!._value = snapshot?.value as? [String: AnyObject]
        }
        layer.insertSublayer(_zoneViewLayer, atIndex: 0)
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
    var _zoneViewLayer = CAShapeLayer()
    var _value: [String: AnyObject]? {
        didSet {
            shapes = _value?["shapes"] as? [String: Shape] ?? [String: Shape]()
            
            let newSelection = Set(selectionIDs.filter({ shapes[$0] != nil }))
            if newSelection != selectionIDs {
                selectionIDs = newSelection
            }
            
            if let v = _value, width = v["width"] as? CGFloat, height = v["height"] as? CGFloat {
                coordinateSpace.size = CGSizeMake(width, height)
            }
            
            if let v = _value, let ownerID = v["owner"] as? String, let uid = API.Shared.uid {
                userIsOwner = (ownerID == uid)
            }
            
            if _value != nil && !initialLoadCompleted {
                initialLoadCompleted = true
                delegate.canvasViewInitialLoadCompleted(self)
            }
        }
    }
    private(set) var userIsOwner: Bool!
    private(set) var initialLoadCompleted = false
    
    // MARK: Rendering
    override func render() {
        super.render()
        let selectedShapeViews = selectionIDs.map({ self._viewsByID[$0] }).filter({ $0 != nil }).map({ $0! })
        _drawSelectionIndicators(selectedShapeViews)
        _updateZoneViewLayer()
    }
    
    func _updateZoneViewLayer() {
        let path = CGPathCreateMutable()
        if let zones = _value?["zones"] as? [String: AnyObject] {
            for zone in zones.values {
                if let rect = zone as? [CGFloat] where rect.count == 4 {
                    let cgRect = coordinateSpace.convertRect(CGRectMake(rect[0], rect[1], rect[2], rect[3]), toCoordinateSpace: self)
                    CGPathAddRect(path, nil, cgRect)
                }
            }
        }
        _zoneViewLayer.path = path
        _zoneViewLayer.fillColor = nil
        _zoneViewLayer.strokeColor = UIColor.grayColor().CGColor
    }
    
    // MARK: Delegate
    @IBOutlet weak var delegate: CanvasViewDelegate!
    
    // MARK: Selection
    var selectionIDs = Set<String>() {
        didSet {
            _needsRender = true
            delegate.canvasView(self, selectionChanged: selectionIDs)
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
    
    func canEditShapeWithID(id: String) -> Bool {
        if let author = authorForShape(id), let authorID = author["id"] as? String {
            return authorID == API.Shared.uid
        } else {
            return false
        }
    }
}
