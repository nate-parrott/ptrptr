//
//  UIImage+Resize.swift
//  StickerApp
//
//  Created by Nate Parrott on 9/6/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized
    }
    func resizedWithMaxDimension(maxDimension: CGFloat) -> UIImage {
        let scale = min(maxDimension / size.width, maxDimension / size.height)
        if scale >= 1 {
            return self
        } else {
            return resizeTo(CGSizeMake(size.width * scale, size.height * scale))
        }
    }
}
