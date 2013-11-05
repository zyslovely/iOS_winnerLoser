//
//  WLGameInfo.m
//  WinerLoser
//
//  Created by Tom on 11/25/12.
//  Copyright (c) 2012 Tom. All rights reserved.
//

#import "WLGameInfo.h"
#import "Utilities.h"

#define kGameID       @"gameID"
#define kGameIndex    @"gameIndex"
#define kRoundIndex   @"roundIndex"
#define kCashOutIndex @"cashOutIndex"
#define kAttendees    @"attendees"
#define kType         @"type"
#define kAdditionalInfo  @"additionalInfo"

@implementation WLGameInfo

- (void)dealloc {
  
  [_attendees release];
  [_gameID    release];
  [_additionalInfoDic release];
  
  [super dealloc];
}

- (id)init {
  
  self = [super init];
  if (self) {
    _attendees    = [[NSMutableArray alloc] init];
    _gameIndex    = 0;
    _roundIndex   = 1;
    _cashOutIndex = 0;
    
    _additionalInfoDic = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)setType:(WLGameType)type {
  
  if(type == WL_GAME_GAN_DENG_YAN){
    
    [self.additionalInfoDic setObject:[NSNumber numberWithDouble:0.5] forKey:kINFO_GDY_CARDVALUE];
  }else {
    
    [self.additionalInfoDic removeAllObjects];
  }
  _type = type;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  
  [aCoder encodeObject:self.gameID forKey:kGameID];
  [aCoder encodeObject:self.attendees forKey:kAttendees];
  [aCoder encodeObject:self.additionalInfoDic forKey:kAdditionalInfo];
  
  [aCoder encodeInteger:self.gameIndex forKey:kGameIndex];
  [aCoder encodeInteger:self.roundIndex forKey:kRoundIndex];
  [aCoder encodeInteger:self.cashOutIndex forKey:kCashOutIndex];
  [aCoder encodeInteger:self.type forKey:kType];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  
  self = [super init];
  if (self) {
    
    _gameID = [[aDecoder decodeObjectForKey:kGameID] copy];
    _attendees = [[aDecoder decodeObjectForKey:kAttendees] retain];
    _additionalInfoDic = [[aDecoder decodeObjectForKey:kAdditionalInfo] retain];
    
    _gameIndex = [aDecoder decodeIntegerForKey:kGameIndex];
    _roundIndex = [aDecoder decodeIntegerForKey:kRoundIndex];
    _cashOutIndex = [aDecoder decodeIntegerForKey:kCashOutIndex];
    _type = [aDecoder decodeIntegerForKey:kType];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  
  WLGameInfo *copy = [[[self class] allocWithZone:zone] init];
  
  copy.gameID = [[_gameID copyWithZone:zone] autorelease];
  copy.attendees = [[_attendees copyWithZone:zone] autorelease];
  copy.additionalInfoDic = [[_additionalInfoDic copyWithZone:zone] autorelease];
  
  copy.gameIndex = _gameIndex;
  copy.roundIndex = _roundIndex;
  copy.cashOutIndex = _cashOutIndex;
  copy.type = _type;
  
  return copy;
}

- (void)cleanInfoAndRestart {
  
  [self.attendees removeAllObjects];
  self.gameID = [[NSDate date] pd_yyyyMMddThhmmssZZZString];
  [self.additionalInfoDic removeAllObjects];
  self.gameIndex = 0;
  self.roundIndex = 1;
  self.cashOutIndex = 0;
  self.type = WL_GAME_NORMAL;
}

@end
