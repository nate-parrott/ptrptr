//
//  MediaCache.swift
//  ptrptr
//
//  Created by Nate Parrott on 1/20/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class MediaCache {
    let Shared = MediaCache()
    
    var _ids = [String: [_Item]]()
    class _Item {
        var lastAccess: CFAbsoluteTime!
        var image: UIImage!
    }
    let _maxImageAge: CFAbsoluteTime = 2
    
    func storeImage(image: UIImage, id: String) {
        let item = _Item()
        item.image = image
        item.lastAccess = CFAbsoluteTimeGetCurrent()
        _storeItem(item, id: id)
    }
    
    func getImage(id: String, preferredWidth: CGFloat, fetchURL: NSURL?) -> UIImage? {
        // will return an image NOT MUCH LARGER than the one you requested:
        let itemsBiggestFirst = (_ids[id] ?? []).sort({ $0.image.size.width > $1.image.size.width })
        if let goodSizeMatch = itemsBiggestFirst.filter({ self.sizesAreCloseEnough($0.image.size.width, width2: preferredWidth) }).first {
            goodSizeMatch.lastAccess = CFAbsoluteTimeGetCurrent()
            return goodSizeMatch.image
        }
        if let match = itemsBiggestFirst.first {
            if match.image.size.width > preferredWidth {
                // it's too big -- scale it down:
                let newItem = _Item()
                let scale = preferredWidth / match.image.size.width
                newItem.image = match.image.resizeTo(match.image.size * scale)
                newItem.lastAccess = CFAbsoluteTimeGetCurrent()
                _storeItem(newItem, id: id)
                return newItem.image
            } else {
                // start a fetch:
                _ensureFetching(id, width: preferredWidth, url: fetchURL)
                match.lastAccess = CFAbsoluteTimeGetCurrent()
                return match.image
            }
        }
        _ensureFetching(id, width: preferredWidth, url: fetchURL)
        return nil
    }
    
    class _FetchTask {
        var width: CGFloat!
        var task: NSURLSessionDataTask!
        var lastAccess: CFAbsoluteTime!
    }
    
    var _fetchesInProgressAtSizesById = [String: _FetchTask]()
    func _ensureFetching(id: String, width: CGFloat, url url_: NSURL?) {
        if let url = url_ {
            let task = _fetchesInProgressAtSizesById[id] ?? _FetchTask()
            task.lastAccess = CFAbsoluteTimeGetCurrent()
            _fetchesInProgressAtSizesById[id] = task
            let needsLoad = task.width == nil || (width > task.width && !sizesAreCloseEnough(task.width, width2: width))
            if needsLoad {
                task.task?.cancel()
                task.width = width
                task.task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url), completionHandler: { [weak self] (let dataOpt, let responseOpt, let errorOpt) -> Void in
                        if let data = dataOpt, let image = UIImage(data: data) {
                            let item = _Item()
                            item.lastAccess = CFAbsoluteTimeGetCurrent()
                            item.image = image
                            self!._storeItem(item, id: id)
                        }
                        self!._fetchesInProgressAtSizesById.removeValueForKey(id)
                    })
                task.task.resume()
                task.lastAccess = CFAbsoluteTimeGetCurrent()
                _fetchesInProgressAtSizesById[id] = task
            }
        }
    }
    
    func _storeItem(item: _Item, id: String) {
        if _ids[id] == nil {
            _ids[id] = []
        }
        _ids[id]!.append(item)
    }
    
    func deleteStaleImages() {
        let now = CFAbsoluteTimeGetCurrent()
        for (id, items) in _ids {
            _ids[id] = items.filter({ now - $0.lastAccess < self._maxImageAge })
        }
    }
    
    func sizesAreCloseEnough(width1: CGFloat, width2: CGFloat) -> Bool {
        let proportion = min(width1, width2) / max(width1, width2)
        return proportion >= 0.8
    }
}
