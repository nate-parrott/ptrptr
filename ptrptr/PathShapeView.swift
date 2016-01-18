//
//  PathShapeView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class PathShapeView: ShapeView {
    
    class _ShapeLayerView: UIView {
        override class func layerClass() -> AnyClass {
            return CAShapeLayer.self
        }
        var shapeLayer: CAShapeLayer {
            get {
                return self.layer as! CAShapeLayer
            }
        }
    }
    
    override func setup() {
        super.setup()
        addSubview(_strokeShapeView)
        _strokeShapeView.shapeLayer.fillColor = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _strokeShapeView.frame = bounds
        _fillMaskShapeView.frame = bounds
        _fillView?.frame = bounds
    }
    
    func setPathsAndFrame(paths: [[CGFloat]], inCoordinateSpace: ShapesView.CoordinateSpace, offset: CGPoint) {
        // this layer will be scaled automatically to fit the space; we just need to set the correct center position
        let bezier = UIBezierPath()
        for path in paths {
            for i in 0..<(path.count/2) {
                let pt = CGPointMake(path[i*2], path[i*2+1])
                if i == 0 {
                    bezier.moveToPoint(pt)
                } else {
                    bezier.addLineToPoint(pt)
                }
            }
        }
        let pathBounds = bezier.bounds
        bezier.applyTransform(CGAffineTransformMakeTranslation(-pathBounds.origin.x, -pathBounds.origin.y))
        
        let cgPath = bezier.CGPath
        _strokeShapeView.shapeLayer.path = cgPath
        _fillMaskShapeView.shapeLayer.path = cgPath
        
        center = inCoordinateSpace.convertPoint(pathBounds.center + offset, toCoordinateSpace: inCoordinateSpace.view)
        bounds = CGRectMake(0, 0, pathBounds.size.width, pathBounds.size.height)
    }
    
    // MARK: stroke/fill
    enum Fill: Equatable {
        case Color(UIColor)
        case Image(UIImage)
        case ImageURL(NSURL)
    }
    
    var fill: Fill? {
        willSet(newVal) {
            if newVal != fill {
                // update fill:
                var fillView: UIView?
                var shapeFillColor: UIColor?
                
                if let newValFill = newVal {
                    switch newValFill {
                    case .Color(let color):
                        shapeFillColor = color
                    case .Image(let image):
                        let imageView = _fillView as? NetImageView ?? NetImageView()
                        imageView.image = image
                        fillView = imageView
                    case .ImageURL(let url):
                        let imageView = _fillView as? NetImageView ?? NetImageView()
                        imageView.url = url
                        fillView = imageView
                    }
                }
                
                _strokeShapeView.shapeLayer.fillColor = shapeFillColor?.CGColor
                _fillView = fillView
            }
        }
    }
    
    var _strokeShapeView = _ShapeLayerView()
    var _fillMaskShapeView = _ShapeLayerView()
    var _fillView: UIView? {
        willSet(newVal) {
            if newVal !== _fillView {
                _fillView?.removeFromSuperview()
                _fillView?.maskView = nil
                if let view = newVal {
                    addSubview(view)
                    view.maskView = _fillMaskShapeView
                }
            }
        }
    }
    
    var stroke: (UIColor?, CGFloat) = (nil, 0) {
        didSet {
            _strokeShapeView.shapeLayer.strokeColor = stroke.0?.CGColor
            _strokeShapeView.shapeLayer.lineWidth = stroke.1
        }
    }
}

func ==(lhs: PathShapeView.Fill, rhs: PathShapeView.Fill) -> Bool {
    switch (lhs, rhs) {
    case (.Color(let color1), .Color(let color2)): return color1 == color2
    case (.Image(let image1), .Image(let image2)): return image1 === image2
    case (.ImageURL(let url1), .ImageURL(let url2)): return url1 === url2
    default: return false
    }
}
