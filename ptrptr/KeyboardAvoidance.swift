//
//  KeyboardAvoidance.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/17/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class _KeyboardTracker: NSObject {
    static let Shared = _KeyboardTracker()
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "_frameChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        UIApplicationDidChangeStatusBarOrientationNotification
    }
    
    
    var frame: CGRect?
    
    func _frameChanged(notif: NSNotification) {
        frame = (notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    }
    
}

class KeyboardProxyView: UIView {
    // currently assumes it's pinned to the bottom of the window
    
    var _notifications: Bool = false {
        willSet(newVal) {
            if _notifications != newVal {
                if newVal {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "_frameChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
                } else {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                }
            }
        }
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        _notifications = (newWindow != nil)
        _updateSize(_KeyboardTracker.Shared.frame)
    }
    
    func _frameChanged(notif: NSNotification) {
        let frame = (notif.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        _updateSize(frame)
    }
    
    func _updateSize(kbFrame: CGRect?) {
        var keyboardHeight: CGFloat = 0
        if let frame = kbFrame {
            switch UIApplication.sharedApplication().statusBarOrientation {
            case .LandscapeLeft, .LandscapeRight:
                keyboardHeight = frame.size.width
            default:
                keyboardHeight = frame.size.height
            }
        }
        _height = keyboardHeight
    }
    
    var _height: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(0, _height)
    }
}
