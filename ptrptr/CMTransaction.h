//
//  CMTransaction.h
//  computer
//
//  Created by Nate Parrott on 11/30/15.
//  Copyright © 2015 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CMTransactionStackDidExecuteTransactionNotification;

typedef void (^CMTransactionBlock)(id target);

@interface CMTransaction : NSObject

- (instancetype)initWithTarget:(id)target action:(CMTransactionBlock)action undo:(CMTransactionBlock)inverse;
- (instancetype)initNonFinalizedWithTarget:(id)target action:(CMTransactionBlock)action undo:(CMTransactionBlock)inverse;
- (instancetype)initImplicitlyFinalizaledWhenTouchesEndWithTarget:(id)target action:(CMTransactionBlock)action undo:(CMTransactionBlock)inverse;
@property (nonatomic,copy) CMTransactionBlock action, inverse; // action can be nil
@property (nonatomic) id target;
@property (nonatomic) BOOL finalized;

@end

@interface CMTransactionStack : NSObject

- (void)doTransaction:(CMTransaction *)transaction;
@property (nonatomic,readonly) BOOL canUndo, canRedo;
- (void)undo;
- (void)redo;
- (void)_transactionDidUpdate:(CMTransaction *)t; // internal only

@end
