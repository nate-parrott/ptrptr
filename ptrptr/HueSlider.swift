//
//  HueSlider.swift
//  PatternPicker
//
//  Created by Nate Parrott on 11/15/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

import UIKit

class HueGradientView: UIImageView {
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        render()
        contentMode = .ScaleToFill
    }
    
    func render() {
        let pixels = UnsafeMutablePointer<PixelData>.alloc(256)
        let (satC, valC) = satVal
        var sat = Float(satC)
        var val = Float(valC)
        if sat == 0 {
            sat = 0.2
        }
        if val == 0 {
            val = 0.2
        }
        
        for i in 0..<256 {
            var r: Float = 0
            var g: Float = 0
            var b: Float = 0
            HSVtoRGB(&r, &g, &b, Float(i) / 255.0 * 360, sat, val)
            r = min(1, r)
            g = min(1, g)
            b = min(1, b)
            pixels[i] = PixelData(a: 255, r: UInt8(r*Float(255.0)), g: UInt8(g*Float(255.0)), b: UInt8(b*Float(255.0)))
        }
        self.image = imageFromARGB32Bitmap(pixels, width: 256, height: 1)
        pixels.destroy()
    }
    
    var satVal: (CGFloat, CGFloat) = (1,1) {
        willSet(new) {
            render()
        }
    }
}

class HueSlider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        addSubview(_gradient)
        addSubview(_bar)
        _bar.backgroundColor = UIColor.whiteColor()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "_change:"))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "_change:"))
    }
    
    func _change(sender: UIGestureRecognizer) {
        hue = min(1, max(0, sender.locationInView(self).x / bounds.size.width))
    }
    
    var _gradient = HueGradientView()
    var hue: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var _bar = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _gradient.frame = bounds
        
        let w: CGFloat = 4
        let pad = w*2
        _bar.bounds = CGRectMake(0, 0, w, bounds.size.height)
        _bar.center = CGPointMake(pad + (bounds.size.width - pad*2) * hue, bounds.size.height/2)
    }
}
