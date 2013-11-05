//
//  WLCashOutObj.h
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLCashOutObj : NSObject

@property (nonatomic,copy) NSString     *userName;
@property (nonatomic)      NSUInteger   userID;
@property (nonatomic) double            shouldValue;
@property (nonatomic) double            actualValue;
@property (nonatomic) BOOL              isWinner;
@property (nonatomic) BOOL              isPayer;

@end
