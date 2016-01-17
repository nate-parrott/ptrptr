//
//  Colors.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

func GetUserColor(user: User) -> UIColor {
    let userColor = user["color"] as? [CGFloat] ?? [1,0,0,1]
    return UIColor(red: userColor[0], green: userColor[1], blue: userColor[2], alpha: 1)
}

func CreateColorFunctionForUserColor(color: UIColor) -> ([CGFloat] -> UIColor) {
    let userHue = color.hsva.0
    
    return { (channels: [CGFloat]) -> UIColor in
        let color = channels.count == 4 ? UIColor(red: channels[0], green: channels[1], blue: channels[2], alpha: channels[3]) : UIColor.redColor()
        var (_,s,v,a) = color.hsva
        v = max(0.2, v)
        s = max(0.2, s)
        a = max(0.2, a)
        return UIColor(hue: userHue, saturation: s, brightness: v, alpha: a)
    }
}

extension UIColor {
    var hsva: (CGFloat, CGFloat, CGFloat, CGFloat) {
        get {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var v: CGFloat = 0
            var a: CGFloat = 0
            if !getHue(&h, saturation: &s, brightness: &v, alpha: &a) {
                if getWhite(&v, alpha: &a) {
                    s = 0
                }
            }
            return (h,s,v,a)
        }
    }
    
    var rgba: (CGFloat, CGFloat, CGFloat, CGFloat) {
        get {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            if !getRed(&r, green: &g, blue: &b, alpha: &a) {
                var brightness: CGFloat = 1
                if getWhite(&brightness, alpha: &a) {
                    r = brightness
                    g = brightness
                    b = brightness // TODO: this is not 100% correct
                }
            }
            return (r,g,b,a)
        }
    }
}
