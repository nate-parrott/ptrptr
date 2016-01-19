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
                label.numberOfLines = 0
                label.backgroundColor = UIColor.whiteColor()
                
                addSubview(lastModifiedLabel)
                lastModifiedLabel.text = "about 2 weeks ago".uppercaseString
                lastModifiedLabel.font = UIFont.boldSystemFontOfSize(14)
                lastModifiedLabel.textAlignment = .Right
                lastModifiedLabel.textColor = UIColor.grayColor()
            }
            label.text = ""
            if let c = canvas {
                label.text = c.description()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 10
        lastModifiedLabel.frame = CGRectMake(padding, padding, bounds.size.width - padding*2, 14 + padding*2)
        label.frame = CGRectMake(0, lastModifiedLabel.frame.bottom, bounds.size.width, bounds.size.height - lastModifiedLabel.frame.bottom)
    }
    
    let label = UILabel()
    let lastModifiedLabel = UILabel()
}
