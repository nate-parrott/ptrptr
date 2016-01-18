//
//  CMWindow.h
//  computer
//
//  Created by Nate Parrott on 12/1/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CMWindowGlobalTouchesBeganNotification;
extern NSString * const CMWindowGlobalTouchesEndedNotification;

@interface CMWindow : UIWindow

@property (nonatomic,readonly) BOOL touchesAreDown;

@end
