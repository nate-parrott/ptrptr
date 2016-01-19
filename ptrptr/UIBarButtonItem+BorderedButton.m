//
//  UIBarButtonItem+BorderedButton.m
//  iossketch
//
//  Created by Nate Parrott on 11/20/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import "UIBarButtonItem+BorderedButton.h"

@implementation UIBarButtonItem (BorderedButton)

- (instancetype)initBorderedWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    CGFloat padding = 5;
    CGFloat fontSize = 14;
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:@{NSFontAttributeName: font}];
    CGFloat textWidth = [str size].width;
    
    CGSize size = CGSizeMake(textWidth + padding*2, fontSize + padding*2);
    
    // create mask:
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    [str drawAtPoint:CGPointMake(padding, padding-1)];
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // create image:
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [[UIColor blackColor] setFill];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:3] fill];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClipToMask(ctx, CGRectMake(0, 0, size.width, size.height), mask.CGImage);
    CGContextClearRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self = [self initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
    self.accessibilityLabel = title;
    return self;
}

- (instancetype)initUnborderedWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    CGFloat padding = 0;
    CGFloat fontSize = 14;
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:title.uppercaseString attributes:@{NSFontAttributeName: font}];
    CGFloat textWidth = [str size].width;
    
    CGSize size = CGSizeMake(textWidth + padding*2, fontSize + padding*2);
    
    // create image:
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [[UIColor blackColor] setFill];
    [str drawAtPoint:CGPointMake(padding, padding)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self = [self initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
    self.accessibilityLabel = title;
    self.width = size.width;
    
    return self;
}

@end
