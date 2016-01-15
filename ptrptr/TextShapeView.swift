//
//  TextShapeView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class TextShapeView: ShapeView {
    let _label = UILabel()
    override func layoutSubviews() {
        super.layoutSubviews()
        _label.frame = bounds
    }
    
    var content: (NSAttributedString, CGSize) = (NSAttributedString(), CGSizeMake(100, 100)) {
        willSet(newVal) {
            if !(newVal.0 == content.0 && newVal.1 == content.1) {
                let (string, size) = newVal
                bounds = CGRectMake(0, 0, size.width, size.height)
                _label.attributedText = string.resizeToFitInside(size)
                if _label.superview == nil {
                    // set up label:
                    addSubview(_label)
                    _label.numberOfLines = 0
                }
            }
        }
    }
}
