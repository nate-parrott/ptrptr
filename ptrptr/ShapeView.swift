//
//  ShapeView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/13/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

class ShapeView: UIView {
    var _id: String!
    weak var _shapesView: ShapesView!
    var _canvasView: CanvasView? {
        return _shapesView as? CanvasView
    }
    
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
    
    func doubleClicked() -> Bool {
        return false
    }
    
    func doubleClickActionName() -> String? {
        return nil
    }
    
    func shapeOptions() -> [ShapeOption] {
        let delete = ShapeOption(title: NSLocalizedString("Delete", comment: ""), action: {
            (let view: ShapeView, let firebase: Firebase, let canvasVC: CanvasViewController) -> () in
            firebase.setValue(nil)
        })
        return [delete]
    }
}
