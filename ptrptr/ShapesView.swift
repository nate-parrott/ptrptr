//
//  ShapesView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class ShapesView: UIView {
    var _viewsByID = [String: ShapeView]()
    func render(shapes: [(String, Shape)]) {
        for (id, shape) in shapes {
            if let user = shape["author"] as? User {
                let existingOpt: ShapeView? = _viewsByID[id]
                let renderCtx = RenderContext(coordinateSpace: coordinateSpace, colorFunc: CreateColorFunctionForUser(user))
                let view = Shapes.renderShape(id, shape: shape, existingView: existingOpt, ctx: renderCtx)
                if view.superview !== self {
                    _viewsByID[id]?.removeFromSuperview()
                    _viewsByID[id] = view
                    addSubview(view)
                } else {
                    bringSubviewToFront(view)
                }
            } else {
                print("Shape with no user!") // TODO: remove? too much logging?
            }
        }
        let usedIDs = Set(shapes.map({$0.0}))
        for id in Array(_viewsByID.keys) {
            if !usedIDs.contains(id) {
                _viewsByID[id]!.removeFromSuperview()
                _viewsByID.removeValueForKey(id)
            }
        }
    }
    
    class CoordinateSpace: NSObject, UICoordinateSpace {
        init(view: UIView) {
            self.view = view
            super.init()
        }
        let view: UIView
        var size: CGSize = CGSizeMake(1000, 1000)
        var bounds: CGRect {
            get {
                return CGRectMake(0, 0, size.width, size.height)
            }
        }
        var scale: CGFloat { // multiply by canvas coords to get view coords
            get {
                return min(view.bounds.size.width / size.width, view.bounds.size.height / size.height)
            }
        }
        var offset: CGPoint { // add to view coords after scaling
            get {
                let s = scale
                return CGPointMake((view.bounds.size.width - s * bounds.size.width)/2, (view.bounds.size.height - s * bounds.size.height)/2)
            }
        }
        func convertPoint(point: CGPoint, fromCoordinateSpace coordinateSpace: UICoordinateSpace) -> CGPoint {
            let pointInView = coordinateSpace.convertPoint(point, toCoordinateSpace: view)
            return (pointInView - offset) / scale
        }
        func convertPoint(point: CGPoint, toCoordinateSpace coordinateSpace: UICoordinateSpace) -> CGPoint {
            let pointInView = point * scale + offset
            return view.convertPoint(pointInView, toCoordinateSpace: coordinateSpace)
        }
        func convertRect(rect: CGRect, fromCoordinateSpace coordinateSpace: UICoordinateSpace) -> CGRect {
            var r = rect
            r.origin = convertPoint(r.origin, fromCoordinateSpace: coordinateSpace)
            r.size.width /= scale
            r.size.height /= scale
            return r
        }
        func convertRect(rect: CGRect, toCoordinateSpace coordinateSpace: UICoordinateSpace) -> CGRect {
            var r = rect
            r.origin = convertPoint(r.origin, toCoordinateSpace: coordinateSpace)
            r.size.width *= scale
            r.size.height *= scale
            return r
        }
    }
    lazy var coordinateSpace: CoordinateSpace = {
        return CoordinateSpace(view: self)
    }()
    
    struct RenderContext {
        let coordinateSpace: CoordinateSpace
        let colorFunc: [CGFloat] -> UIColor // parses and enforces color constraints
    }
}
