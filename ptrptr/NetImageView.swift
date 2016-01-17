//
//  NetImageView.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/16/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class NetImageView: UIImageView {
    var url: NSURL? {
        willSet(newVal) {
            image = nil
            if newVal != url {
                _task?.cancel()
                _task = nil
                loadInProgress = true
                if let url_ = newVal {
                    let req = NSURLRequest(URL: url_)
                    _task = NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { [weak self] (let dataOpt, let responseOpt, let errorOpt) -> Void in
                        backgroundThread({ () -> Void in
                            if let self_ = self, data = dataOpt, image = UIImage(data: data) {
                                mainThread({ () -> Void in
                                    if self_.url == url_ {
                                        self_.image = image
                                        self_.loadInProgress = false
                                    }
                                })
                            }
                        })
                    })
                    _task!.resume()
                }
            } else {
                loadInProgress = false
            }
        }
    }
    
    var _task: NSURLSessionDataTask?
    
    private(set) var loadInProgress = false {
        didSet {
            backgroundColor = loadInProgress ? UIColor(white: 0.5, alpha: 0.5) : UIColor.clearColor()
        }
    }
}
