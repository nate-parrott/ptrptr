//
//  SelectionIndicatorView.m
//  computer
//
//  Created by Nate Parrott on 12/5/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "SelectionIndicatorView.h"

@interface SelectionIndicatorView () {
    UIImageView *_topLeft, *_topRight, *_bottomLeft, *_bottomRight;
}

@end

@implementation SelectionIndicatorView

- (instancetype)init {
    self = [super init];
    
    _topLeft = [UIImageView new];
    _topRight = [UIImageView new];
    _bottomLeft = [UIImageView new];
    _bottomRight = [UIImageView new];
    CGFloat angle = 0;
    for (UIImageView *v in @[_topLeft, _topRight, _bottomRight, _bottomLeft]) {
        v.image = [UIImage imageNamed:@"Corner"];
        [v sizeToFit];
        v.transform = CGAffineTransformMakeRotation(angle);
        angle += M_PI / 2;
        [self addSubview:v];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat p = _topLeft.bounds.size.width/2;
    _topLeft.center = CGPointMake(p, p);
    _topRight.center = CGPointMake(self.bounds.size.width-p, p);
    _bottomLeft.center = CGPointMake(p, self.bounds.size.height-p);
    _bottomRight.center = CGPointMake(self.bounds.size.width-p, self.bounds.size.height-p);
}

@end
