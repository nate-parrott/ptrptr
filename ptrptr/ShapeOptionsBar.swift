//
//  ShapeOptionsBar.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/19/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import Firebase

struct ShapeOption {
    let title: String
    let action: (view: ShapeView, firebase: Firebase, canvasVC: CanvasViewController) -> ()
}

class ShapeOptionsBar: EditModeBar {
    let scrollView = _ScrollView()
    let _scrollViewContainer = UIView()
    class _ScrollView: UIScrollView {
        override func touchesShouldCancelInContentView(view: UIView) -> Bool {
            if (view as? UIControl) != nil {
                return true
            } else {
                return super.touchesShouldCancelInContentView(view)
            }
        }
    }
    let closeButton = UIButton()
    let hint = UILabel()
    let _scrollViewMask = GradientView()
    
    weak var shapeView: ShapeView? {
        didSet {
            if let s = shapeView {
                hint.text = s.doubleClickActionName()
                options = s.shapeOptions()
            }
        }
    }
    
    var options = [ShapeOption]() {
        didSet {
            if scrollView.superview == nil {
                // do some setup:
                tintColor = UIColor.blackColor()
                
                addSubview(_scrollViewContainer)
                
                _scrollViewContainer.addSubview(scrollView)
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.canCancelContentTouches = true
                
                closeButton.setImage(UIImage(named: "X"), forState: .Normal)
                closeButton.addTarget("self", action: "_close:", forControlEvents: .TouchUpInside)
                addSubview(closeButton)
                
                addSubview(hint)
                hint.font = UIFont.systemFontOfSize(11)
                hint.textAlignment = .Center
                hint.textColor = UIColor.blackColor()
                hint.userInteractionEnabled = false
                hint.alpha = 0.5
                
                backgroundColor = AppColors.Emerald
                
                _scrollViewContainer.maskView = _scrollViewMask
                _scrollViewMask.userInteractionEnabled = false
                _scrollViewMask.startPoint = CGPointZero
                _scrollViewMask.endPoint = CGPointMake(1, 0)
            }
            _buttons = options.map() {
                (option: ShapeOption) -> UIButton in
                let b = UIButton()
                b.setTitle(option.title.uppercaseString, forState: .Normal)
                b.titleLabel!.font = UIFont.boldSystemFontOfSize(13)
                b.addTarget(self, action: "_selected:", forControlEvents: .TouchUpInside)
                b.setTitleColor(UIColor.blackColor(), forState: .Normal)
                return b
            }
        }
    }
    
    var _buttons = [UIButton]() {
        willSet(newVal) {
            for btn in _buttons { btn.removeFromSuperview() }
            for btn in newVal { scrollView.addSubview(btn) }
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _scrollViewContainer.frame = bounds
        let padding: CGFloat = 10
        let hintHeight: CGFloat = (hint.text == nil || hint.text! == "") ? 0 : 18
        closeButton.sizeToFit()
        closeButton.frame = CGRectMake(0, 0, closeButton.bounds.size.width + padding * 2, bounds.size.height)
        scrollView.frame = bounds
        scrollView.contentInset = UIEdgeInsetsMake(0, closeButton.bounds.size.width, 0, 0)
        var x: CGFloat = 0
        for btn in _buttons {
            btn.sizeToFit()
            btn.frame = CGRectMake(x, 0, btn.bounds.size.width + padding*2, bounds.size.height)
            x = btn.frame.origin.x + btn.frame.size.width
            // btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, hintHeight/2, 0)
        }
        scrollView.contentSize = CGSizeMake(x, bounds.size.height)
        hint.frame = CGRectMake(0, bounds.size.height - hintHeight, bounds.size.width, hintHeight)
        _scrollViewMask.frame = bounds
        _scrollViewMask.stops = [
            GradientView.Stop(color: UIColor(white: 0, alpha: 0), location: (closeButton.frame.size.width - padding)/bounds.size.width),
            GradientView.Stop(color: UIColor(white: 0, alpha: 1), location: (closeButton.frame.size.width + padding)/bounds.size.width)
        ]
    }
    
    func _selected(sender: UIButton) {
        let option = options[_buttons.indexOf(sender)!]
        
        option.action(view: shapeView!, firebase: shapeView!._canvasView!.canvas.childByAppendingPath("shapes").childByAppendingPath(shapeView!._id), canvasVC: canvasVC)
    }
    
    func _close(sender: UIButton) {
        canvasVC.canvasView!.selectionIDs = []
    }
}
