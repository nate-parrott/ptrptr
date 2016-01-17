//
//  ViewCollection.swift
//  ColorSchemer
//
//  Created by Nate Parrott on 1/11/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class ViewCollection: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: API
    
    var models: [AnyObject] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var viewFunction: ((AnyObject, UIView?) -> UIView) = {
        (model: AnyObject, oldView: UIView?) in
        let v = oldView ?? UIView()
        return v
    }
    
    var selectedModel: AnyObject? {
        didSet {
            // TODO
        }
    }
    
    var onSelectedModel: (AnyObject -> ())?
    
    // MARK: For subclasses
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    func _setup() {
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: createLayout())
        collectionView.registerClass(_Cell.self, forCellWithReuseIdentifier: "Cell")
        addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    // MARK: CollectionView
    var collectionView: UICollectionView!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! _Cell
        cell.view = viewFunction(models[indexPath.item], cell.view)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cb = onSelectedModel {
            cb(models[indexPath.item])
        }
    }
    
    class _Cell: UICollectionViewCell {
        var view: UIView? {
            willSet(newVal) {
                if newVal === view {return}
                if let v = view {
                    v.removeFromSuperview()
                }
                if let v = newVal {
                    contentView.addSubview(v)
                }
            }
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            if let v = view {
                v.frame = bounds
            }
        }
    }

}
