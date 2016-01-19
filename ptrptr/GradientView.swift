//
//  GradientView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    struct Stop {
        let color: UIColor
        let location: CGFloat
    }
    var gradientLayer: CAGradientLayer {
        get {
            return layer as! CAGradientLayer
        }
    }
    var startPoint: CGPoint {
        get {
            return gradientLayer.startPoint
        }
        set(val) {
            gradientLayer.startPoint = val
        }
    }
    var endPoint: CGPoint {
        get {
            return gradientLayer.endPoint
        }
        set(val) {
            gradientLayer.endPoint = val
        }
    }
    var stops: [Stop] {
        get {
            return zip(gradientLayer.colors as! [CGColor], gradientLayer.locations as! [CGFloat]).map({ Stop(color: UIColor(CGColor: $0.0), location: $0.1) })
        }
        set(val) {
            gradientLayer.colors = val.map({ $0.color.CGColor })
            gradientLayer.locations = val.map({ $0.location })
        }
    }
}
