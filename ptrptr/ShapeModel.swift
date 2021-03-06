//
//  Shapes.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class ShapeModel {
    required init(data: [String: AnyObject], id: String) {
        self.data = data
        self.id = id
    }
    let data: [String: AnyObject]
    let id: String
    func renderToView(existing: ShapeView?, context: ShapesView.RenderContext) -> ShapeView! {
        let view = existing ?? ShapeView()
        view._id = self.id
        view.alpha = data["opacity"] as? CGFloat ?? 1
        let rotation = data["rotation"] as? CGFloat ?? 0
        let scale = (data["scale"] as? CGFloat ?? 1) * context.coordinateSpace.scale
        if let x = data["x"] as? CGFloat, let y = data["y"] as? CGFloat {
            view.center = context.coordinateSpace.convertPoint(CGPointMake(x, y), toCoordinateSpace: context.coordinateSpace.view)
        }
        view.transformation = (rotation: rotation, scale: scale)
        return view
    }
    class func classForType(type: String) -> ShapeModel.Type {
        switch type {
            case "path": return PathShapeModel.self
            case "text": return TextShapeModel.self
            default: return self
        }
    }
    class func renderShape(id: String, shape: Shape, existingView: ShapeView?, ctx: ShapesView.RenderContext) -> ShapeView? {
        let type = shape["type"] as? String ?? ""
        let model = classForType(type).init(data: shape, id: id)
        if ctx.overlapsBoundingCircle(model.computeBoundingCircle()) {
            return model.renderToView(existingView, context: ctx)
        } else {
            // print("skipping \(type)")
            return nil
        }
    }
    class func convertShapeDictToArray(shapes: [String: Shape]) -> [(String, Shape)] {
        return shapes.map({ $0 }).sort({ (pair1, pair2) -> Bool in
            let z1 = pair1.1["z"] as? Double ?? 0
            let z2 = pair2.1["z"] as? Double ?? 0
            return z1 < z2
        })
    }
    func computeBoundingCircle() -> (center: CGPoint, radius: CGFloat) {
        let center = CGPointMake(data["x"] as? CGFloat ?? 0, data["y"] as? CGFloat ?? 0)
        return (center: center, radius: 0)
    }
}

class PathShapeModel: ShapeModel {
    override func renderToView(existing: ShapeView?, context: ShapesView.RenderContext) -> ShapeView! {
        var view = (existing as? PathShapeView) ?? PathShapeView()
        view = super.renderToView(view, context: context) as! PathShapeView
        
        let paths = getPathsArray()
        let offset = CGPointMake(data["x"] as? CGFloat ?? 0, data["y"] as? CGFloat ?? 0)
        view.setPathsAndFrame(paths, inCoordinateSpace: context.coordinateSpace, offset: offset)
        
        var strokeColor: UIColor?
        var strokeWidth: CGFloat = 0
        if let stroke = data["stroke"] as? [String: AnyObject] {
            strokeWidth = stroke["width"] as? CGFloat ?? 0
            if let colorArray = stroke["color"] as? [CGFloat] {
                strokeColor = context.colorFunc(colorArray)
            }
        }
        
        var fill: PathShapeView.Fill?
        if let fillDict = data["fill"] as? [String: AnyObject] {
            let type = fillDict["type"] as? String ?? ""
            switch type {
            case "solid":
                if let colorArray = fillDict["color"] as? [CGFloat] {
                    fill = PathShapeView.Fill.Color(context.colorFunc(colorArray))
                }
            case "image":
                if  let width = fillDict["width"] as? CGFloat,
                    let height = fillDict["height"] as? CGFloat,
                    let id = fillDict["id"] as? String {
                        var url: NSURL?
                        if let urlString = fillDict["url"] as? String,
                            let url_ = NSURL(string: urlString) {
                                url = url_
                        }
                        fill = PathShapeView.Fill.DynamicImage(url, CGSizeMake(width, height), id)
                }
                // images need a border
                if strokeColor == nil {
                    strokeColor = context.userColor
                }
                if strokeWidth == 0 {
                    strokeWidth = 3
                }
            default: ()
            }
        }
        view.fill = fill
        view.stroke = (strokeColor, strokeWidth)
        
        return view
    }
    func getPathsArray() -> [[CGFloat]] {
        var paths = [[CGFloat]]()
        if let pathArrays = data["paths"] as? [AnyObject] {
            for pathArray in pathArrays {
                if let points = pathArray as? [CGFloat] {
                    paths.append(points)
                }
            }
        }
        return paths
    }
    class func bezierPathFromPathsArray(paths: [[CGFloat]]) -> UIBezierPath {
        let bezier = UIBezierPath()
        for path in paths {
            var firstPoint: CGPoint?
            for i in 0..<(path.count/2) {
                let pt = CGPointMake(path[i*2], path[i*2+1])
                if i == 0 {
                    firstPoint = pt
                    bezier.moveToPoint(pt)
                } else if i + 1 == path.count/2 && pt == firstPoint {
                    // last point is same as first point
                    bezier.closePath()
                } else {
                    bezier.addLineToPoint(pt)
                }
            }
        }
        return bezier
    }
    override func computeBoundingCircle() -> (center: CGPoint, radius: CGFloat) {
        var circle = super.computeBoundingCircle()
        let pathBounds = self.dynamicType.bezierPathFromPathsArray(getPathsArray()).bounds
        if !isinf(pathBounds.origin.x) {
            circle.center = circle.center + pathBounds.center
            circle.radius = pathBounds.origin.distanceFrom(pathBounds.center)
        }
        return circle
    }
}

class TextShapeModel: ShapeModel {
    override func renderToView(existing: ShapeView?, context: ShapesView.RenderContext) -> ShapeView! {
        var view = (existing as? TextShapeView) ?? TextShapeView()
        view = super.renderToView(view, context: context) as! TextShapeView
        
        let text = data["text"] as? String ?? ""
        var color = UIColor.redColor()
        if let colorArray = data["color"] as? [CGFloat] {
            color = context.colorFunc(colorArray)
        }
        
        let w = data["width"] as? CGFloat ?? 200
        view.content = (text, getFont(), color, w)
        
        return view
    }
    func getFont() -> UIFont {
        return UIFont.systemFontOfSize(30)
    }
    override func computeBoundingCircle() -> (center: CGPoint, radius: CGFloat) {
        var circle = super.computeBoundingCircle()
        let text = data["text"] as? String ?? ""
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName: getFont()])
        let width = data["width"] as? CGFloat ?? 200
        let height = attributedText.boundingRectWithSize(CGSizeMake(width, 99999), options: [.UsesLineFragmentOrigin], context: nil).size.height
        circle.radius = max(width, height)/2
        return circle
    }
}
