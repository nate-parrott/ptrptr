//
//  QuickCollectionModal.h
//  computer
//
//  Created by Nate Parrott on 10/19/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickCollectionItem : NSObject

@property (nonatomic) UIImage *icon;
@property (nonatomic) NSString *label;
@property (nonatomic,copy) void (^action)();
@property (nonatomic) UIColor *color;

@end

@interface QuickCollectionModal : UIViewController

@property (nonatomic) NSArray<__kindof QuickCollectionItem*> *items;

@property (nonatomic) CGSize itemSize;

@property (nonatomic) UIView *topBar;

@end
