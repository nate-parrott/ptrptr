//
//  UIBarButtonItem+BorderedButton.h
//  iossketch
//
//  Created by Nate Parrott on 11/20/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BorderedButton)

- (instancetype)initBorderedWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initUnborderedWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
