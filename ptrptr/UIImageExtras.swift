//
//  UIImageExtras.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/21/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

extension UIImage {
    var hasAlpha: Bool {
        get {
            let info = CGImageGetAlphaInfo(CGImage)
            return info == .First || info == .Last || info == .PremultipliedFirst || info == .PremultipliedLast
        }
    }
}
