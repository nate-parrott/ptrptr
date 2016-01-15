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
        case "path":
            view = renderPath(shape, existingView: view, ctx: ctx)
        case "text":
            view = renderText(shape, existingView: view, ctx: ctx)
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
    
    static func renderPath(shape: Shape, existingView: ShapeView?, ctx: ShapesView.RenderContext) -> ShapeView {
        var view = (existingView as? PathShapeView) ?? PathShapeView()
        view = renderBase(shape, existingView: view, ctx: ctx) as! PathShapeView
        
        let path = shape["path"] as? [CGFloat] ?? []
        view.setPathAndFrame(path, inCoordinateSpace: ctx.coordinateSpace)
        
        var strokeColor: CGColorRef?
        var strokeWidth: CGFloat = 0
        if let stroke = shape["stroke"] as? [String: AnyObject] {
            strokeWidth = stroke["width"] as? CGFloat ?? 0
            if let colorArray = stroke["color"] as? [CGFloat] {
                strokeColor = ctx.colorFunc(colorArray).CGColor
            }
        }
        
        var fillColor: CGColorRef?
        if let fill = shape["fill"] as? [String: AnyObject] {
            let type = fill["type"] as? String ?? ""
            if type == "solid", let colorArray = fill["color"] as? [CGFloat] {
                fillColor = ctx.colorFunc(colorArray).CGColor
            }
        }
        
        view.shapeLayer.fillColor = fillColor
        view.shapeLayer.lineWidth = strokeWidth
        view.shapeLayer.strokeColor = strokeColor
        
        return view
    }
    
    static func renderText(shape: Shape, existingView: ShapeView?, ctx: ShapesView.RenderContext) -> ShapeView {
        var view = (existingView as? TextShapeView) ?? TextShapeView()
        view = renderBase(shape, existingView: view, ctx: ctx) as! TextShapeView
        
        let text = shape["text"] as? String ?? ""
        var color = UIColor.redColor()
        if let colorArray = shape["color"] as? [CGFloat] {
            color = ctx.colorFunc(colorArray)
        }
        
        let attributed = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color])
        let w = shape["width"] as? CGFloat ?? 200
        let h = shape["height"] as? CGFloat ?? 100
        view.content = (attributed, CGSizeMake(w, h))
        
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
