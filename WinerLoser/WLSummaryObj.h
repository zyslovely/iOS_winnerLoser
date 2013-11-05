//
//  WLSummaryObj.h
//  WinerLoser
//
//  Created by Tom on 11/24/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLSummaryObj : NSObject

@property (nonatomic,copy) NSString     *userName;
@property (nonatomic)      NSUInteger   userID;
@property (nonatomic,copy) NSString     *totalScoreString;
@property (nonatomic,copy) NSString     *unPaidString;
@property (nonatomic) BOOL              isRoundLimitationReached;

- (id)initWithUserID:(NSUInteger )userID userName:(NSString *)userName gameID:(NSString *)gameID;

@end
