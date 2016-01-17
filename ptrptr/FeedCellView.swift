//
//  FeedCellView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/17/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class FeedCellView: UIView {
    var canvas: Firebase? {
        didSet {
            if label.superview == nil {
                // do some setup:
                addSubview(label)
                backgroundColor = UIColor.whiteColor()
            }
            label.text = ""
            if let c = canvas {
                label.text = c.description()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    let label = UILabel()
}
