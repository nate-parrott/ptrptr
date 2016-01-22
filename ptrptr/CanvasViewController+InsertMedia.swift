//
//  CanvasViewController+InsertMedia.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/20/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

extension CanvasViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func insertMedia() {
        let actionSheet = UIAlertController(title: NSLocalizedString("Insert photo from…", comment: ""), message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .Default, handler: { (_) -> Void in
            self.insertMedia(.PhotoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .Default, handler: { (_) -> Void in
            self.insertMedia(.Camera)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Never mind", comment: ""), style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    func insertMedia(source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage as String] // , kUTTypeMovie as String]
        picker.sourceType = source
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            insertImage(image)
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func insertImage(var image: UIImage) {
        let useJpeg = !image.hasAlpha // check alpha on _original image_ before resizing
        
        let imageID = NSUUID().UUIDString
        image = image.resizedWithMaxDimension(API.Shared.MaxImageSize)
        
        let fillDict = [
            "type": "image",
            "id": imageID,
            "width": image.size.width,
            "height": image.size.height
        ]
        
        let maxDimension: CGFloat = 60
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
        let size = image.size * scale
        
        var json = API.Shared.getJsonForNewShape("path", userIsOwner: canvasView!.userIsOwner)
        let center = canvasView!.coordinateSpace.convertPoint(canvasView!.bounds.center, fromCoordinateSpace: canvasView!)
        json["x"] = center.x
        json["y"] = center.y
        json["paths"] = [[-size.width,-size.height,   size.width,-size.height,   size.width,size.height,   -size.width,size.height, -size.width,-size.height]]
        json["fill"] = fillDict
        
        MediaCache.Shared.storeImage(image, id: imageID)
        
        var undidInsert = false
        let firebase = canvas.childByAppendingPath("shapes").childByAutoId()
        transactionStack.doTransaction(CMTransaction(target: nil, action: { (_) -> Void in
            firebase.setValue(json)
            undidInsert = false
            }, undo: { (_) -> Void in
                firebase.setValue(nil)
                undidInsert = true
        }))
        
        let data = (useJpeg ? UIImageJPEGRepresentation(image, 0.5) : UIImagePNGRepresentation(image))!
        let mime = useJpeg ? "image/jpeg" : "image/png"
        API.Shared.uploadAsset(data, contentType: mime, callback: { (urlOpt, error) -> () in
            if let url = urlOpt {
                if !undidInsert {
                    firebase.childByAppendingPath("fill").childByAppendingPath("url").setValue(url.absoluteString)
                }
                // update `json` in case we redo the insertion:
                var fill = json["fill"] as! [String: AnyObject]
                fill["url"] = url.absoluteString
                json["fill"] = fill
            } // TODO: show if upload fails
        })
    }
}
