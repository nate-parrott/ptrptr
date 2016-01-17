//
//  InsertItemViewController.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/17/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class InsertItemViewController: QuickCollectionModal {
    var parent: CanvasViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = QuickCollectionItem()
        text.label = NSLocalizedString("Text", comment: "")
        text.action = {
            [weak self] in
            
        }
        
        let square = QuickCollectionItem()
        square.label = NSLocalizedString("Square", comment: "")
        square.action = {
            [weak self] in
            // self!.insertPath(UIBezierPath(rect: CGRectMake(0, 0, 100, 100)))
        }
        
        let circle = QuickCollectionItem()
        circle.label = NSLocalizedString("Circle", comment: "")
        circle.action = {
            [weak self] in
            // self!.insertPath(UIBezierPath(ovalInRect: CGRectMake(0, 0, 100, 100)))
        }
        
        let image = QuickCollectionItem()
        image.label = NSLocalizedString("Image", comment: "")
        image.action = {
            [weak self] in
            
        }
        
        let link = QuickCollectionItem()
        link.label = NSLocalizedString("Link", comment: "")
        link.action = {
            [weak self] in
        }
        
        let page = QuickCollectionItem()
        page.label = NSLocalizedString("Page", comment: "")
        page.action = {
            [weak self] in
        }
        
        let counter = QuickCollectionItem()
        counter.label = NSLocalizedString("Counter", comment: "")
        counter.action = {
            [weak self] in
        }
        
        let sketch = QuickCollectionItem()
        sketch.label = NSLocalizedString("Sketch", comment: "")
        sketch.action = {
            [weak self] in
            self!.parent.startDrawing()
        }
        
        items = [text, square, circle, image, link, page, counter, sketch]
    }
}
