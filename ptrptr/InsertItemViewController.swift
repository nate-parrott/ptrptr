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
        
        let size: CGFloat = 50
        
        let text = QuickCollectionItem()
        text.label = NSLocalizedString("Text", comment: "")
        text.action = {
            [weak self] in
            self!.insertText()
        }
        
        let emoji = QuickCollectionItem()
        emoji.label = NSLocalizedString("Emoji", comment: "")
        emoji.action = {
            [weak self] in
            
        }
        
        let square = QuickCollectionItem()
        square.label = NSLocalizedString("Square", comment: "")
        square.action = {
            [weak self] in
            let square: [[CGFloat]] = [[-size,-size,    size,-size,   size,size,   -size,size]]
            self!.insertShape(square)
        }
        
        let circle = QuickCollectionItem()
        circle.label = NSLocalizedString("Circle", comment: "")
        circle.action = {
            [weak self] in
            var path = [CGFloat]()
            let nPoints = 30
            for i in 0..<(nPoints+1) {
                let angle = Float(i) / Float(nPoints) * Float(M_PI * 2)
                path.append(CGFloat(cosf(angle)) * size)
                path.append(CGFloat(sinf(angle)) * size)
            }
            self!.insertShape([path])
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
        
        let particle = QuickCollectionItem()
        particle.label = NSLocalizedString("Particle FX", comment: "")
        particle.action = {
            [weak self] in
        }
        
        let sketch = QuickCollectionItem()
        sketch.label = NSLocalizedString("Sketch", comment: "")
        sketch.action = {
            [weak self] in
            self!.parent.startDrawing()
        }
        
        items = [text, square, circle, image, link, page, counter, sketch, emoji, particle]
    }
    
    func insertedItemWithID(id: String) {
        delay(0.1) { () -> () in
            self.parent.canvasView!.selectionIDs = [id]
        }
    }
    
    func insertText() {
        var json = API.Shared.getJsonForNewShape("text", userIsOwner: parent.canvasView!.userIsOwner)
        json["text"] = "your text here"
        json["color"] = API.Shared.userColor
        let center = parent.canvasView!.coordinateSpace.convertPoint(parent.canvasView!.bounds.center, fromCoordinateSpace: parent.canvasView!)
        json["x"] = center.x
        json["y"] = center.y
        json["width"] = 250
        let shapeFirebase = parent.canvas.childByAppendingPath("shapes").childByAutoId()
        parent.transactionStack.doTransaction(CMTransaction(target: nil, action: { (_) -> Void in
            shapeFirebase.setValue(json)
            }, undo: { (_) -> Void in
                shapeFirebase.setValue(nil)
        }))
        insertedItemWithID(shapeFirebase.lastPathComponent)
    }
    
    func insertShape(paths: [[CGFloat]], additionalJson: [String: AnyObject]?=nil) {
        var json = API.Shared.getJsonForNewShape("path", userIsOwner: parent.canvasView!.userIsOwner)
        json["paths"] = paths
        let center = parent.canvasView!.coordinateSpace.convertPoint(parent.canvasView!.bounds.center, fromCoordinateSpace: parent.canvasView!)
        json["x"] = center.x
        json["y"] = center.y
        json["fill"] = ["type": "solid", "color": API.Shared.userColor]
        let shapeFirebase = parent.canvas.childByAppendingPath("shapes").childByAutoId()
        parent.transactionStack.doTransaction(CMTransaction(target: nil, action: { (_) -> Void in
            shapeFirebase.setValue(json)
            }, undo: { (_) -> Void in
                shapeFirebase.setValue(nil)
        }))
        insertedItemWithID(shapeFirebase.lastPathComponent)
    }
}
