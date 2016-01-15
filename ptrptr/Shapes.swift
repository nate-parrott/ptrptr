//
//  Shapes.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

struct Shapes {
    static func renderShape(id: String, shape: Shape, existingView: ShapeView?, ctx: ShapesView.RenderContext) -> ShapeView {
        let type = shape["type"] as? String ?? ""
        var view: ShapeView!
        switch type {
        default:
            view = renderBase(shape, existingView: existingView, ctx: ctx)
        }
        view._id = id
        return view
    }
    
    static func renderBase(shape: Shape, existingView: ShapeView?, ctx: ShapesView.RenderContext) -> ShapeView {
        let view = existingView ?? ShapeView()
        
        view.alpha = shape["opacity"] as? CGFloat ?? 1
        let rotation = shape["rotation"] as? CGFloat ?? 0
        let scale = (shape["scale"] as? CGFloat ?? 1) * ctx.coordinateSpace.scale
        if let x = shape["x"] as? CGFloat, let y = shape["y"] as? CGFloat {
            view.center = ctx.coordinateSpace.convertPoint(CGPointMake(x, y), toCoordinateSpace: ctx.coordinateSpace.view)
        }
        view.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(rotation * CGFloat(M_PI) / 180.0), scale, scale)
        return view
    }
    
    static func convertShapeDictToArray(shapes: [String: Shape]) -> [(String, Shape)] {
        return shapes.map({ $0 }).sort({ (pair1, pair2) -> Bool in
            let z1 = pair1.1["z"] as? Double ?? 0
            let z2 = pair2.1["z"] as? Double ?? 0
            return z1 < z2
        })
    }
}
