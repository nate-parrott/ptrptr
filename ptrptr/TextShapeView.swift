//
//  TextShapeView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/15/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class TextShapeView: ShapeView, UITextViewDelegate {
    let _textView = UITextView()
    
    override func setup() {
        super.setup()
        addSubview(_textView)
        _textView.scrollEnabled = false
        _textView.backgroundColor = nil
        _textView.textContainerInset = UIEdgeInsetsZero
        _textView.delegate = self
        _textView.returnKeyType = .Done
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _textView.frame = bounds
    }
    
    var content: (String, UIColor, CGFloat) = ("", UIColor.blackColor(), 100) {
        willSet(newVal) {
            if !(newVal.0 == content.0 && newVal.1 == content.1 && newVal.2 == content.2) {
                let selection = _textView.selectedRange
                
                /*let (string, size) = newVal
                bounds = CGRectMake(0, 0, size.width, size.height)
                let selection = _textView.selectedRange
                _textView.attributedText = string.resizeToFitInside(size)
                if _textView.selectedRange.location + _textView.selectedRange.length <= _textView.text.utf16.count {
                    _textView.selectedRange = selection
                }*/
                let (string, color, maxWidth) = newVal
                let font = UIFont.systemFontOfSize(30)
                let attributed = NSAttributedString(string: string, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
                _textView.attributedText = attributed
                let size = _textView.sizeThatFits(CGSizeMake(maxWidth, 99999))
                let width = max(70, size.width)
                let scale = maxWidth / width // maxWidth is typically 250
                bounds = CGRectMake(0, 0, size.width*scale, size.height*scale)
                _textView.transform = CGAffineTransformMakeScale(scale, scale)
                _textView.center = bounds.center
                _textView.bounds = CGRectMake(0, 0, size.width, size.height)
                
                if _textView.selectedRange.location + _textView.selectedRange.length <= _textView.text.utf16.count {
                    _textView.selectedRange = selection
                }
            }
        }
    }
    
    var _editingTransaction: CMTransaction?
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textViewDidChange(textView: UITextView) {
        let textFirebase = _canvasView!.canvas.childByAppendingPath("shapes").childByAppendingPath(_id).childByAppendingPath("text")
        if _editingTransaction == nil {
            let oldText = content.0
            _editingTransaction = CMTransaction(target: nil, action: { (_) -> Void in
                
                }, undo: { (_) -> Void in
                    textFirebase.setValue(oldText)
            })
            _canvasView!.transactionStack.doTransaction(_editingTransaction!)
        }
        let newText = textView.text
        _editingTransaction!.action = {
            (_) in
            textFirebase.setValue(newText)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        _editingTransaction?.finalized = true
        _editingTransaction = nil
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if _textView.isFirstResponder() {
            return super.hitTest(point, withEvent: event)
        } else {
            return nil
        }
    }
    
    override func doubleClicked() -> Bool {
        _textView.becomeFirstResponder()
        _textView.selectedRange = NSMakeRange(0, _textView.text.utf16.count)
        return true
    }
    
    override func doubleClickActionName() -> String? {
        return NSLocalizedString("Double-click to edit text", comment: "")
    }
}
