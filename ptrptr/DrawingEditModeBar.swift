//
//  DrawingEditModeBar.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/17/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class DrawingEditModeBar: EditModeBar {
    @IBAction func confirm() {
        canvasVC.popEditMode()
    }
    override func modalCanvasOverlay() -> UIView? {
        let o = _SketchOverlayView()
        o.editBar = self
        return o
    }
}

class _SketchOverlayView: UIView {
    weak var editBar: DrawingEditModeBar!
    
    var paths = [[CGFloat]]()
    var shape: Firebase?
    
    var _transaction: CMTransaction?
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let insertShape = (shape == nil)
        if insertShape {
            shape = editBar.canvasVC!.canvas.childByAppendingPath("shapes").childByAutoId()
            var json = API.Shared.getJsonForNewShape("path", userIsOwner: editBar.canvasVC.canvasView!.userIsOwner)
            json["stroke"] = ["color": API.Shared.userColor, "width": 2]
            shape!.setValue(json)
        }
        let oldPaths = paths
        let curShape = shape!
        _transaction = CMTransaction(implicitlyFinalizaledWhenTouchesEndWithTarget: self, action: nil, undo: { [weak self] (let target) -> Void in
            if insertShape {
                // delete shape:
                curShape.setValue(NSNull())
                self?.shape = nil
            } else {
                curShape.childByAppendingPath("paths").setValue(oldPaths)
            }
            self?.paths = oldPaths
        })
        editBar.canvasVC.transactionStack.doTransaction(_transaction)
        paths.append([])
        _appendTouchPoint(touches.first!)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _transaction!.action = nil // trigger update
        _appendTouchPoint(touches.first!)
    }
    func _appendTouchPoint(touch: UITouch) {
        let canvasView = editBar.canvasVC.canvasView!
        let ptInCanvas = touch.locationInView(canvasView)
        let pt = canvasView.coordinateSpace.convertPoint(ptInCanvas, fromCoordinateSpace: canvasView)
        for c in [pt.x, pt.y] {
            shape!.childByAppendingPath("paths").childByAppendingPath("\(paths.count-1)/\(paths.last!.count)").setValue(c)
            paths[paths.count-1].append(c)
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
}
