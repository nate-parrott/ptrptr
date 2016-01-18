//
//  ShapeView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    var _id: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
    }
    
    var transformation: (rotation: CGFloat, scale: CGFloat) = (rotation: 0, scale: 1) {
        didSet {
            let (rotation, scale) = transformation
            transform = CGAffineTransformRotate(CGAffineTransformMakeScale(scale, scale), rotation)
        }
    }
}
