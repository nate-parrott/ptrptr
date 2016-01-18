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
        
        var paths = [[CGFloat]]()
        if let pathArrays = shape["paths"] as? [AnyObject] {
            for pathArray in pathArrays {
                if let points = pathArray as? [CGFloat] {
                    paths.append(points)
                }
            }
        }
        let offset = CGPointMake(shape["x"] as? CGFloat ?? 0, shape["y"] as? CGFloat ?? 0)
        view.setPathsAndFrame(paths, inCoordinateSpace: ctx.coordinateSpace, offset: offset)
        
        var strokeColor: UIColor?
        var strokeWidth: CGFloat = 0
        if let stroke = shape["stroke"] as? [String: AnyObject] {
            strokeWidth = stroke["width"] as? CGFloat ?? 0
            if let colorArray = stroke["color"] as? [CGFloat] {
                strokeColor = ctx.colorFunc(colorArray)
            }
        }
        
        var fill: PathShapeView.Fill?
        if let fillDict = shape["fill"] as? [String: AnyObject] {
            let type = fillDict["type"] as? String ?? ""
            switch type {
            case "solid":
                if let colorArray = fillDict["color"] as? [CGFloat] {
                    fill = PathShapeView.Fill.Color(ctx.colorFunc(colorArray))
                }
            case "image":
                if let urlString = fillDict["url"] as? String, url = NSURL(string: urlString) {
                    fill = PathShapeView.Fill.ImageURL(url)
                }
                // images need a border
                if strokeColor == nil {
                    strokeColor = ctx.userColor
                }
                if strokeWidth == 0 {
                    strokeWidth = 2
                }
            default: ()
            }
        }
        view.fill = fill
        view.stroke = (strokeColor, strokeWidth)
        
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
