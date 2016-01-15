//
//  PathShapeView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class PathShapeView: ShapeView {
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer: CAShapeLayer { // for convenience
        get {
            return layer as! CAShapeLayer
        }
    }
    
    func setPathAndFrame(path: [CGFloat], inCoordinateSpace: ShapesView.CoordinateSpace) {
        // this layer will be scaled automatically to fit the space; we just need to set the correct center position
        let bezier = UIBezierPath()
        for i in 0..<(path.count/2) {
            let pt = CGPointMake(path[i*2], path[i*2+1])
            if i == 0 {
                bezier.moveToPoint(pt)
            } else {
                bezier.addLineToPoint(pt)
            }
        }
        let pathBounds = bezier.bounds
        bezier.applyTransform(CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y))
        shapeLayer.path = bezier.CGPath
        center = inCoordinateSpace.convertPoint(pathBounds.center, toCoordinateSpace: inCoordinateSpace.view)
        bounds = CGRectMake(0, 0, pathBounds.size.width, pathBounds.size.height)
    }
}
