//
//  CanvasView+Gestures.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/18/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

extension CanvasView {
    func _setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "_tapped:"))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "_pinched:"))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "_panned:"))
    }
    func _tapped(rec: UITapGestureRecognizer) {
        if rec.state == .Recognized {
            let pt = rec.locationInView(self)
            let hitTestResults = hitTestAtPoint(pt, accuracy: HitTestAccuracyDirect) + hitTestAtPoint(pt, accuracy: HitTestAccuracyVicinity)
            let editableHitTestViews = hitTestResults.filter({ self.canMoveShapeWithID($0._id) })
            let selectionOpt = editableHitTestViews.first ?? hitTestResults.first
            selectionIDs = selectionOpt == nil ? [] : [selectionOpt!._id]
        }
    }
    func _pinched(rec: UIPinchGestureRecognizer) {
        
    }
    func _panned(rec: UIPanGestureRecognizer) {
        
    }
}
