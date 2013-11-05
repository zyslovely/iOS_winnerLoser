//
//  WLScoreObj.h
//  WinerLoser
//
//  Created by Tom on 1/16/13.
//  Copyright (c) 2013 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLScoreObj : NSObject

@property (nonatomic) BOOL  isWinner;
@property (nonatomic) double score;
@property (nonatomic, copy) NSString *scoreString;
@property (nonatomic) NSUInteger cardsleft;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic) NSUInteger userID;
@property (nonatomic) BOOL  selected;

- (void)resetScoreString:(double)score;

@end
