//
//  WLGameInfo.h
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kINFO_GDY_CARDVALUE @"card_value"
typedef enum WLGameType_ {
  
  WL_GAME_NORMAL          = 0,
  WL_GAME_GAN_DENG_YAN    = 1
  
}WLGameType;

@interface WLGameInfo : NSObject

@property (nonatomic, copy)NSString   *gameID;
@property (nonatomic) NSUInteger      gameIndex;
@property (nonatomic) NSUInteger      roundIndex;
@property (nonatomic) NSUInteger      cashOutIndex;
@property (nonatomic, retain)NSMutableArray  *attendees;
@property (nonatomic) WLGameType      type;
@property (nonatomic, retain) NSMutableDictionary    *additionalInfoDic;

- (void)cleanInfoAndRestart;
- (void)setType:(WLGameType)type;

@end
