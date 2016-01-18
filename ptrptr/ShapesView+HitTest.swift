//
//  ShapesView+HitTest.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/18/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

typealias HitTestAccuracy = Int
let HitTestAccuracyDirect: HitTestAccuracy = 2
let HitTestAccuracyVicinity: HitTestAccuracy = 1
let HitTestAccuracyNone: HitTestAccuracy = 0

extension ShapesView {
    func hitTestAtPoint(point: CGPoint, accuracy: HitTestAccuracy) -> [ShapeView] {
        let matches = _viewsByID.values.filter({ self.hitTestPointForView($0, point: point) >= accuracy })
        // sort by z (highest first):
        return matches.sort({ $0.superview!.subviews.indexOf($0)! > $1.superview!.subviews.indexOf($1)! })
    }
    
    func hitTestPointForView(view: ShapeView, point: CGPoint) -> HitTestAccuracy {
        let minBoundingRadius: CGFloat = 30
        
        if view.pointInside(convertPoint(point, toView: view), withEvent: nil) {
            return HitTestAccuracyDirect
        } else if view.center.distanceFrom(point) <= max(_boundingRadiusForView(view), minBoundingRadius) {
            return HitTestAccuracyVicinity
        } else {
            return HitTestAccuracyNone
        }
    }
    
    func _boundingRadiusForView(view: ShapeView) -> CGFloat {
        return max(view.bounds.size.width, view.bounds.size.height) * view.transformation.scale / 2
    }
}
