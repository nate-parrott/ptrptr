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

class CanvasView: ShapesView {
    // MARK: Lifecycle
    init(canvas: Firebase) {
        self.canvas = canvas
        super.init(frame: CGRectZero)
        _valueObserverToken = canvas.observeEventType(.Value) { [weak self] (snapshot: FDataSnapshot?) -> Void in
            self!._value = snapshot?.value as? [String: AnyObject]
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let canvas: Firebase!
    var _valueObserverToken: UInt?
    var _value: [String: AnyObject]? {
        didSet {
            _needsRender = true
            
            if let v = _value, width = v["width"] as? CGFloat, height = v["height"] as? CGFloat {
                coordinateSpace.size = CGSizeMake(width, height)
            }
        }
    }
    
    // MARK: Delegate
    @IBOutlet var delegate: CanvasViewDelegate!
    
    // MARK: Selection
    var selection = [Firebase]()
    
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
            }
        }
    }
}
