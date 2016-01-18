//
//  CMWindow.m
//  computer
//
//  Created by Nate Parrott on 12/1/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "CMWindow.h"


NSString * const CMWindowGlobalTouchesBeganNotification = @"CMWindowGlobalTouchesBeganNotification";
NSString * const CMWindowGlobalTouchesEndedNotification = @"CMWindowGlobalTouchesEndedNotification";

@interface CMWindow ()

@property (nonatomic) BOOL touchesAreDown;

@end

@implementation CMWindow

- (void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        [self updateTouches:[event touchesForWindow:self]];
    }
    [super sendEvent:event];
}

- (void)updateTouches:(NSSet *)touches {
    BOOL touchesAreDown = NO;
    for (UITouch *touch in touches) {
        if (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary) {
            touchesAreDown = YES;
        }
    }
    self.touchesAreDown = touchesAreDown;
}

- (void)setTouchesAreDown:(BOOL)touchesAreDown {
    if (touchesAreDown != _touchesAreDown) {
        _touchesAreDown = touchesAreDown;
        if (touchesAreDown) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CMWindowGlobalTouchesBeganNotification object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:CMWindowGlobalTouchesEndedNotification object:self];
        }
    }
}

@end
