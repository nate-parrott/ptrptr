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
        let recs = [
            UITapGestureRecognizer(target: self, action: "_tapped:"),
            UIPinchGestureRecognizer(target: self, action: "_pinched:"),
            UIPanGestureRecognizer(target: self, action: "_panned:"),
            UIRotationGestureRecognizer(target: self, action: "_rotated:")
        ]
        for rec in recs {
            rec.delegate = self
            addGestureRecognizer(rec)
        }
    }
    struct _MovingTransaction {
        let transaction: CMTransaction
        let initialRotation: CGFloat
        let initialScale: CGFloat
        let initialPosition: CGPoint
    }
    func _ensureMovingTransaction() -> Bool {
        if _movingTransaction == nil || _movingTransaction!.transaction.finalized {
            // create new:
            if let shapeID = _shapeToMove, let shapes = _value?["shapes"] as? [String: AnyObject], let shape = shapes[shapeID] as? Shape {
                let rotation = shape["rotation"] as? CGFloat ?? 0
                let scale = shape["scale"] as? CGFloat ?? 1
                let x = shape["x"] as? CGFloat ?? 0
                let y = shape["y"] as? CGFloat ?? 0
                let shapePath = canvas.childByAppendingPath("shapes").childByAppendingPath(shapeID)
                let transaction = CMTransaction(implicitlyFinalizaledWhenTouchesEndWithTarget: nil, action: nil, undo: { (_) -> Void in
                    // restore initial values:
                    shapePath.childByAppendingPath("x").setValue(x)
                    shapePath.childByAppendingPath("y").setValue(y)
                    shapePath.childByAppendingPath("scale").setValue(scale)
                    shapePath.childByAppendingPath("rotation").setValue(rotation)
                })
                transactionStack.doTransaction(transaction)
                _movingTransaction = _MovingTransaction(transaction: transaction, initialRotation:  rotation, initialScale: scale, initialPosition: CGPointMake(x, y))
                
            }
        }
        return _movingTransaction != nil
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let eitherAreTapRecs = (gestureRecognizer as? UITapGestureRecognizer) != nil || (otherGestureRecognizer as? UITapGestureRecognizer) != nil
        return !eitherAreTapRecs
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
        if rec.state == .Changed && _ensureMovingTransaction() {
            let newScale = _movingTransaction!.initialScale * rec.scale
            canvas.childByAppendingPath("shapes").childByAppendingPath(_shapeToMove!).childByAppendingPath("scale").setValue(newScale)
        }
    }
    func _panned(rec: UIPanGestureRecognizer) {
        if rec.state == .Changed && _ensureMovingTransaction() {
            let newPos = _movingTransaction!.initialPosition + rec.translationInView(self) / coordinateSpace.scale
            canvas.childByAppendingPath("shapes").childByAppendingPath(_shapeToMove!).childByAppendingPath("x").setValue(newPos.x)
            canvas.childByAppendingPath("shapes").childByAppendingPath(_shapeToMove!).childByAppendingPath("y").setValue(newPos.y)
        }
    }
    func _rotated(rec: UIRotationGestureRecognizer) {
        if rec.state == .Changed && _ensureMovingTransaction() {
            let newRotation = _movingTransaction!.initialRotation + rec.rotation
            canvas.childByAppendingPath("shapes").childByAppendingPath(_shapeToMove!).childByAppendingPath("rotation").setValue(newRotation)
        }
    }
}
