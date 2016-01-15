//
//  ShapesView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

typealias Shape = [String: AnyObject]

class ShapesView: UIView {
    var _viewsByID = [String: ShapeView]()
    func render(shapes: [(String, Shape)]) {
        
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
    }
}
